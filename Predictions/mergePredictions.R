pred1 <- readRDS("~/Google Drive/Stanford/Stanford Y2 Q1/CS 221/CS221FinalProject/Predictions/predictions_7_107.rds")
pred2 <- readRDS("~/Google Drive/Stanford/Stanford Y2 Q1/CS 221/CS221FinalProject/Predictions/predictions_108_357.rds")
pred3 <- readRDS("~/Google Drive/Stanford/Stanford Y2 Q1/CS 221/CS221FinalProject/Predictions/predictions_358_507.rds")
pred4 <- readRDS("~/Google Drive/Stanford/Stanford Y2 Q1/CS 221/CS221FinalProject/Predictions/predictions_508_1007.rds")

totalPredictions <- cbind(pred1, pred2, pred3, pred4)
saveRDS(totalPredictions, "~/Google Drive/Stanford/Stanford Y2 Q1/CS 221/CS221FinalProject/Predictions/predictions_totalfirst1000.rds")
