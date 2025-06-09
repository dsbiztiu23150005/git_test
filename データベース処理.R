if (!require(duckdb)) install.packages("duckdb")

con <- dbConnect(duckdb(), dbdir = 'test.duckdb', read_only = FALSE)

# データベースにあるテーブルを表示
dbListTables(con)

# 入力するデータを作成
d <- data.frame(name   = c('Taro', 'Jiro'),
                salary = c(600, 550))
d

dbWriteTable(con, 'items', d, append = T)

# テーブルからデータを取得
res <- dbGetQuery(con, "SELECT * FROM items")

print(res)

dbDisconnect(con, shutdown = TRUE)

if (!require(nycflights13)) install.packages("nycflights13")
data("flights", package = "nycflights13") # データの取得


con <- dbConnect(duckdb())
duckdb_register(con, "flights", flights)

res <- dbGetQuery(con,
                  'SELECT origin, dest, n
  FROM (
    SELECT q01.*, RANK() OVER (PARTITION BY origin ORDER BY n DESC) AS col01
    FROM (
      SELECT origin, dest, COUNT(*) AS n
      FROM flights
      GROUP BY origin, dest
    ) q01
  ) q01
  WHERE (col01 <= 3) ORDER BY origin')

duckdb_unregister(con, "flights")  # fligthtsの紐付け解除
dbDisconnect(con, shutdown = TRUE) # データベースの接続解除
print(res)

if (!require(tidyverse)) install.packages("tidyverse")
con <- dbConnect(duckdb()) 

duckdb_register(con, "flights", flights) 

tbl(con, 'flights') |> 
  group_by(origin) |> 
  count(dest) |>
  slice_max(n, n = 3) |> 
  arrange(origin) -> res

print(res) # 結果表示


library(tidyverse)

d <- data.frame(
  name = c("太郎", "花子", "三郎", "良子", "次郎", "桜子", "四郎", "松子", "愛子"),
  school = c("南", "南", "南", "南", "南", "東", "東", "東", "東"),
  teacher = c("竹田", "竹田", "竹田", "竹田",  "佐藤", "佐藤", "佐藤", "鈴木", "鈴木"),
  gender = c("男", "女", "男", "女", "男", "女", "男", "女", "女"),
  math = c(4, 3, 2, 4, 3, 4, 5, 4, 5),
  reading = c(1, 5, 2, 4, 5, 4, 1, 5, 4) )

d

d|>select(name,math)

d|>select(-gender)

d|>slice(3:6)

d|>arrange(name)

d|>select(name,reading)

d|>arrange(desc(math))

d|>arrange(desc(math), desc(reading))

d|>summarize(mean(math))

d|>group_by(teacher)|>summarize(mean(math))

d |>filter(gender == "女")|> pull(math)

d |> filter(school == "南", gender == "男") |> pull(reading)

d |> group_by(teacher) |> filter(n() >= 3)

d |> mutate(total = math + reading)

d |> mutate(math100 = math / 5 * 100)
