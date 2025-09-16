# ab_test_analysis.py
import numpy as np
from statsmodels.stats.proportion import proportions_ztest

# Example numbers (replace with real counts)
# Control: A (no OTP) -> n_A leads, qualified_A qualified leads
# Treatment: B (OTP) -> n_B leads, qualified_B qualified leads

n_A = 1000
qualified_A = 120  # 12% baseline
n_B = 1000
qualified_B = 140  # 14% after OTP

count = np.array([qualified_A, qualified_B])
nobs = np.array([n_A, n_B])

stat, pval = proportions_ztest(count, nobs)
print("z-stat:", stat, "p-value:", pval)

lift_pct = (qualified_B / n_B - qualified_A / n_A) * 100
print(f"Observed lift in QLR: {lift_pct:.2f}%")
