
library(eulerr)
theme_set(theme_bw(base_family = "Arial"))  # Set Arial as the default font

fit <- euler(c(A = 64, B = 58, C = 48, D = 32,
               "A&B" = 45, "A&C" = 0, "A&D" = 0,
               "B&C" = 30, "B&D" = 30, "C&D" = 30,
               "A&B&C" = 0, "A&B&D" = 0, "A&C&D" = 0,
               "B&C&D" = 0, "A&B&C&D" = 0))

library(ggplot2)
library(ggforce)

# Manually specify circle coordinates and sizes
circle_data <- data.frame(
  x = c(2, 5, 11.5, 13.5),  # x-coordinates: separate AD and Aging groups
  y = c(3, 3, 3, 3),        # all circles centered on y = 3
  r = c(4.7, 4.5, 2, 4),    # set radius so Shared Aging wraps around Original Aging
  labels = c("Unique AD", "Original AD", "Original Aging", "AD-linked\nAging"),
  fill_color = c("#FF7F00", "#FDBE85", "#A6C8E3", "#1F78B4")
)

# Text inside each circle (gene count and percentage)
text_data <- data.frame(
  x = c(0.2, 3.9, 8.5, 11.5, 15.5),
  y = c(3, 3, 3, 3, 3),
  label = c("17\n(14%)", "45\n(36%)", "14\n(11%)", "33\n(26%)", "16\n(13%)"),  # 45 is in the overlapping region
  fontface = c("plain", "plain", "plain", "plain", "plain")
)

# Labels for each area (aligned with text x-coordinates)
label_data <- data.frame(
  x = c(0.2, 8.5, 11.5, 15.5),
  y = c(4.5, 4.5, 4.5, 4.5),
  label = c("Unique AD", "Original AD", "Original\nAging", "AD-linked\nAging")
)

# Draw the diagram
ggplot() +
  geom_circle(aes(x0 = x, y0 = y, r = r, fill = fill_color), 
              data = circle_data, color = "black", alpha = 0.85) +
  geom_text(data = label_data, aes(x = x, y = y, label = label),
            size = 5.5, fontface = "bold", hjust = 0.5) +
  geom_text(data = text_data, aes(x = x, y = y, label = label),
            size = 5.2, hjust = 0.5) +
  scale_fill_identity() +
  coord_fixed() +
  theme_void()
