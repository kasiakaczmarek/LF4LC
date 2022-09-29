data=X_summary_segments[X_summary_segments$statistic=="mean",]
png(file = "mean_intensity_boxplot.png")
boxplot(summary_intensity ~ label, data = data, 
        xlab = "Label",
        ylab = "summary_intensity", main = "Mean intensity",
        col = c("green","red"))
# Save the file.
dev.off()

data=X_summary_segments[X_summary_segments$statistic=="std",]
png(file = "std_intensity_boxplot.png")
boxplot(summary_intensity ~ label, data = data, 
        xlab = "Label",
        ylab = "summary_intensity", main = "std intensity",
        col = c("green","red"))
# Save the file.
dev.off()

data=X_summary_segments[X_summary_segments$statistic=="mean",]
png(file = "mean_lengt_boxplot.png")
boxplot(lengt ~ label, data = data, 
        xlab = "Label",
        ylab = "lengt", main = "mean segment length",
        col = c("green","red"))
# Save the file.
dev.off()

data=X_summary_segments[X_summary_segments$statistic=="mean",]
png(file = "mean_dynamics_boxplot.png")
boxplot(dynamics ~ label, data = data, 
        xlab = "Label",
        ylab = "lengt", main = "mean segment dynamics",
        col = c("green","red"))
# Save the file.
dev.off()


acf_good=X_acf[X_acf$label=="_good_", ]
acf_poor=X_acf[!(X_acf$label=="_good_"), ]
summary(acf_good$lag2)
summary(acf_poor$lag2)
