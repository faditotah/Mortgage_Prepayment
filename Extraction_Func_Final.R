library(dplyr)
library(lubridate)
library(zoo)

clean_mortgage_data <- function(D_t_minus1, D_t, D_t_plus1, ref_date, market_rate) {
  
  # Step 1: Keep only loans present in all three datasets
  common_ids <- Reduce(intersect, list(D_t_minus1$RREL3, D_t$RREL3, D_t_plus1$RREL3))
  
  D_t_minus1 <- filter(D_t_minus1, RREL3 %in% common_ids)
  D_t        <- filter(D_t,        RREL3 %in% common_ids)
  D_t_plus1  <- filter(D_t_plus1,  RREL3 %in% common_ids)
  
  print("Step 1")
  print(nrow(Sample))
  
  # Step 2: Apply all filters and removals in order
  Sample <- D_t
  cat("Initial rows:", nrow(Sample), "\n")
  
  Sample <- Sample %>% filter(RREL8 == "ND5")
  cat("After RREL8 == 'ND5':", nrow(Sample), "\n")
  
  Sample <- Sample %>% filter(RREL9 == "ND5")
  cat("After RREL9 == 'ND5':", nrow(Sample), "\n")
  
  Sample <- Sample %>% filter(!RREL16 %in% c("ND3", "ND5"))
  cat("After RREL16 filter:", nrow(Sample), "\n")
  
  Sample <- Sample %>% filter(!is.na(RREL16))
  cat("After RREL16 NA filter:", nrow(Sample), "\n")
  
  Sample <- Sample %>% filter(RREL35 == "FRXX")
  cat("After RREL35 == 'FRXX':", nrow(Sample), "\n")
  
  Sample <- Sample %>% filter(RREL37 == "MNTH")
  cat("After RREL37 == 'MNTH':", nrow(Sample), "\n")
  
  Sample <- Sample %>% filter(RREL38 == "MNTH")
  cat("After RREL38 == 'MNTH':", nrow(Sample), "\n")
  
  Sample <- Sample %>% filter(RREL30 != "0")
  cat("After RREL30 != '0':", nrow(Sample), "\n")
  
  Sample <- Sample %>% filter(RREL43 != "ND5")
  cat("After RREL43 != 'ND5':", nrow(Sample), "\n")
  
  Sample <- Sample %>% filter(RREL74 == "ND5")
  cat("After RREL74 == 'ND5':", nrow(Sample), "\n")
  
  
  print("Step 2")
  print(nrow(Sample))
  
  # Step 3: Feature Engineering before dropping
  
  # Handle both YYYY-MM-DD and DD/MM/YY
  Sample$RREL23 <- parse_date_time(Sample$RREL23, orders = c("Y-m-d", "m/d/y"))
  
  # Then compute age
  Sample$age <- interval(Sample$RREL23, ref_date) %/% months(1)
  
  # Create PrepaymentFee: 1 if not 0 or ND5 or NA, 0 otherwise
  Sample$PrepaymentFee <- ifelse(Sample$RREL61 %in% c("0", "ND5") | is.na(Sample$RREL61), 0, 1)
  
  # Create PrepaymentHistory: 1 if not 0 or ND5 or NA, 0 otherwise
  Sample$PrepaymentHistory <- ifelse(Sample$RREL64 %in% c("0", "ND5") | is.na(Sample$RREL64), 0, 1)
  
  print("Step3")
  print(nrow(Sample))
  
  # Step 4: Explicit variable removal — safe from ordering issues
  vars_to_remove <- c(
    "RREL1", "RREL2", "RREL4", "RREL5", "RREL6", "RREL7", "RREL8", "RREL9",
    "RREL10", "RREL11", "RREL12", "RREL14", "RREL15", "RREL16_CURRENCY", "RREL17",
    "RREL19", "RREL20", "RREL20_CURRENCY", "RREL21", "RREL22", "RREL23", "RREL24", "RREL26",
    "RREL29_CURRENCY", "RREL30_CURRENCY", "RREL31", "RREL31_CURRENCY", "RREL32", "RREL32_CURRENCY",
    "RREL33", "RREL33_CURRENCY", "RREL34", "RREL35", "RREL36", "RREL37", "RREL38",
    "RREL39_CURRENCY", "RREL40", "RREL41", "RREL41_CURRENCY", "RREL44", "RREL45", "RREL46",
    "RREL47", "RREL48", "RREL49", "RREL50", "RREL51", "RREL52", "RREL53", "RREL54", "RREL55",
    "RREL56", "RREL57", "RREL58", "RREL59", "RREL60", "RREL61", "RREL61_CURRENCY",
    "RREL62", "RREL63", "RREL64", "RREL64_CURRENCY", "RREL65", "RREL66", "RREL67_CURRENCY",
    "RREL70", "RREL71_CURRENCY", "RREL72", "RREL73", "RREL73_CURRENCY", "RREL74", "RREL74_CURRENCY",
    "RREL75", "RREL76", "RREL77", "RREL77_CURRENCY", "RREL78", "RREL79", "RREL80", "RREL81",
    "RREL82", "RREL83", "RREL84",
    "RREC1", "RREC3", "RREC4", "RREC5", "RREC8", "RREC10", "RREC11", "RREC13_CURRENCY",
    "RREC14", "RREC15", "RREC18", "RREC19", "RREC20", "RREC21", "RREC21_CURRENCY", "RREC23",
    "Sec_Id.x", "Sec_Id.y", "Pool_Cutoff_Date.x", "Pool_Cutoff_Date.y", "RREC17_CURRENCY"
  )
  
  Sample <- Sample %>% select(-any_of(vars_to_remove))
  
  print("Step4")
  print(nrow(Sample))
  
  # Step 5: Add lagged variables from t-1
  lag_vars <- D_t_minus1 %>%
    select(RREL3, RREL30, RREL39, RREL43, RREC12, RREC13) %>%
    rename_with(~ paste0(.x, "_t_1"), -RREL3)
  
  Sample <- left_join(Sample, lag_vars, by = "RREL3") %>%
    mutate(
      RREL43 = as.numeric(RREL43),
      RREL43_t_1 = as.numeric(RREL43_t_1),
      RREL16 = as.numeric(RREL16),
      incentive = RREL43 - market_rate
    ) %>%
    filter(!is.na(RREL43), !is.na(RREL43_t_1))
  
  print("Step 5")
  print(nrow(Sample))
  
  # Step 6: Create target using t+1 data
  prepay_ids <- D_t_plus1 %>%
    filter(RREL63 != "ND5") %>%
    mutate(RREL63 = as.Date(RREL63)) %>%
    filter(RREL63 > ref_date) %>%
    pull(RREL3) %>%
    unique()
  
  Sample <- Sample %>%
    mutate(target = if_else(RREL3 %in% prepay_ids, 1, 0)) %>%
    select(-RREL3)
  
  print("Step 6")
  print(nrow(Sample))
  
  return(Sample)
}