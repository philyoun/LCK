## Load Data
library(tidyverse)
lck <- read_csv("C:\\Users\\Phil2\\Desktop\\DS\\LCK\\LCK_R1.csv")
lck
n <- nrow(lck) # Number of total games


## Add POG to original data
### 1. Only one POG, 2. POGs -> Casting vote
res <- c()
for(i in 1:n) {
  temp <- table(as_vector(lck[i, 2:13])) # table by votes
  m_number <- max(temp) # POG or POGs
  l <- length(which(temp == m_number))
  if(l > 1) {
    # Case when POGs
    # ANY1, ANY2, OBS1 have casting votes
    temp2 <- table(as_vector(lck[i, c("ANY1", "ANY2", "OBS1")]))
    res[i] <- names(temp2)[which.max(temp2)] # POG by casting votes
  } else {
    # Case when only 1 POG
    res[i] <- names(temp2)[which.max(temp)]
  }
}
lck$POG <- res

########### Correct, Wrong, Percentage table---------------------
tb <- tibble(
  종류 = c("Correct", "Wrong", "Percentage"),
  KOR1 = 0,
  KOR2 = 0,
  ENG1 = 0,
  ENG2 = 0,
  ANY1 = 0,
  ANY2 = 0,
  OBS1 = 0,
  OBS2 = 0,
  OBS3 = 0,
  MED1 = 0,
  MED2 = 0,
  MED3 = 0,
)

### If "each vote" equals to "POG", Correct +1
### If "each vote" not equals to "POG", Wrong +1
for(i in 1:n) {
  pog <- lck[i, 14]
  for(j in 2:13) {
    cond1 <- lck[i, j] == pog
    cond2 <- is.na(cond1) # When voters are absent(accident, etc..)
    if(!cond2) {
      # Voters are 'not' absent most of the cases
      if(cond1) {
        tb[1, j] = tb[1, j] + 1 # Correct +1
      } else {
        tb[2, j] = tb[2, j] + 1 # Wrong +1
      }
    } else {
      # Voters are absent, notice who and when
      cat("At game", paste0(as_vector(lck[i, 1]), ","),
          names(lck[, j]), "was absent.", "\n")
    }
  }
}

### Percentage equals Wrong / (Correct + Wrong)
for(i in 2:13) {
  tb[3, i] <- tb[2, i] / (tb[1, i] + tb[2, i])
}
tb

## Show by graph
graph_tb <- tibble(x = names(tb[3, 2:13]), y = as_vector(tb[3, 2:13]))
ggplot(graph_tb, aes(x = 1:12, y = y)) +
  geom_point(color = "red", size = 3, shape = 19) +
  theme(axis.title.x = element_blank(), 
        axis.ticks.x = element_blank(),
        axis.text.x = element_blank()) +
  labs(y = "Percentage") +
  geom_hline(aes(yintercept=mean(as_vector(tb[3, 2:13])))) +
  scale_y_continuous(limits = c(0.2, 0.5)) +
  geom_text(aes(label=x), size = 5, vjust = -0.5) +
  geom_text(aes(11, mean(as_vector(tb[3, 2:13])), label = "Mean: 0.33"),
            size = 5, vjust = -1)

########### Hongdae score---------------------
tb2 <- tibble(
  "Type" = c("Hongdae"),
  KOR1 = 0,
  KOR2 = 0,
  ENG1 = 0,
  ENG2 = 0,
  ANY1 = 0,
  ANY2 = 0,
  OBS1 = 0,
  OBS2 = 0,
  OBS3 = 0,
  MED1 = 0,
  MED2 = 0,
  MED3 = 0,
)

### Case 1. When POG got more than 6 votes
### Case 2. When POG got 5 votes
### Case 3. When POG got 4 votes

## Case 1.
count1 <- 0 # In how many games did POG get more than 6 votes?
hongdae1 <- 0 # In those games, how many only 1 vote?
for(i in 1:n) {
  temp <- table(as_vector(lck[i, 2:13]))
  cond1 <- max(temp) >= 6 # Check if POG got more than 6 votes
  if(cond1) {
    # For every only 1 vote
    cond2 <- any(temp == 1)
    if(cond2) {
      to_who_idx <- names(which(temp == 1)) # Who got vote?
      for(j in 1:length(to_who_idx)) {
        who_idx <- which(lck[i, 2:13] == to_who_idx[j]) # Whose vote?
        tb2[1, (who_idx + 1)] <- tb2[1, (who_idx + 1)] + 1
        hongdae1 <- hongdae1 + 1
      }
    }
    count1 <- count1 + 1
  }
}

count1 # For 88 games, POG got more than 6 votes
hongdae1 # Among those games, there were 57 times only 1 vote

## Case 2.
pog5_idx <- 0 # In which game did POG get exactly 5 votes?
hongdae2 <- 0 # In those gaems, how many only 1 vote?
for(i in 1:n) {
  temp <- table(as_vector(lck[i, 2:13]))
  if(max(temp) == 5) {
    pog5_idx <- append(pog5_idx, i)
  }
}

## Need to check directly
for(i in pog5_idx) {
  temp <- table(as_vector(lck[i, 2:13]))
  cond <- any(temp == 1)
  if(cond) {
    cat(as_vector(lck[i, 1]))
    print(temp)
    cat("\n")
  }
}

pog5_select <- c(15, 23, 86, 104)
for(i in pog5_select) {
  temp <- table(as_vector(lck[i, 2:13]))
  to_who_idx <- names(which(temp == 1))
  for(j in 1:length(to_who_idx)) {
    who_idx <- which(lck[i, 2:13] == to_who_idx[j])
    tb2[1, (who_idx + 1)] <- tb2[1, (who_idx + 1)] + 1
    hongdae2 <- hongdae2 + 1
  }
}
hongdae2 # Among those games, there were 4 times only 1 vote

## Case 3.
pog4_idx <- 0 # In which game did POG get exactly 4 votes?
hongdae3 <- 0 # In those gaems, how many only 1 vote?
for(i in 1:n) {
  temp <- table(as_vector(lck[i, 2:13]))
  if(max(temp) == 4) {
    pog4_idx <- append(pog4_idx, i)
  }
}

## Need to check directly
for(i in pog4_idx) {
  temp <- table(as_vector(lck[i, 2:13]))
  cond <- any(temp == 1)
  if(cond) {
    cat(as_vector(lck[i, 1]))
    print(temp)
    cat("\n")
  }
}

pog4_select <- c(73)
for(i in pog4_select) {
  temp <- table(as_vector(lck[i, 2:13]))
  to_who_idx <- names(which(temp == 1))
  for(j in 1:length(to_who_idx)) {
    who_idx <- which(lck[i, 2:13] == to_who_idx[j])
    tb2[1, (who_idx + 1)] <- tb2[1, (who_idx + 1)] + 1
    hongdae3 <- hongdae3 + 1
  }
}
hongdae3 # Among thoses games, there was one only 1 vote.

# tb2 # Hongdae score


## Graphs
# Extracting names
who <- names(lck)[2:13]
who

# Assign each names to variables
for(i in who) {
  assign(i, factor(lck[[i]], 
                   levels = c("TOP", "JG", "MID", "BOT", "SUP")))
}

# Get ready for bar graphs
i <- 1 
w <- who[i] # 1-KOR1, 2-KOR2, 3-ENG1, 4-ENG2, 5-ANY1, 6-ANY2,
# 7-OBS1, 8-OBS2, 9-OBS3, 10-MED1, 11-MED2, 12-MED3
h_table <- table(get(w))
h_tb <- tibble(Position = names(h_table),
               Count = h_table,
               Ratio = h_table / sum(h_table))


# Circle graph
ggplot(h_tb, aes(x = "", y = Ratio, fill = Position)) +
  geom_bar(width = 1, size = 5, stat = "identity", color = "white") +
  coord_polar("y") +
  geom_text(aes(label = paste0(round(Ratio*100, 1), "%")), size = 5,
            position = position_stack(vjust = 0.5)) +
  labs(title = paste(w, "Ratio")) +
  theme_void()

# Bar graph
ggplot(h_tb, aes(x = Position, y = Count)) +
  geom_bar(stat = "identity", fill = "#FF6600") + # "#FFCC00"
  labs(title = w) + theme(axis.title.x = element_blank(),
                          axis.ticks.x = element_blank())












