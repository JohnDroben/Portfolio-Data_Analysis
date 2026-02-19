import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt
from statsmodels.stats.proportion import proportions_ztest

st.set_page_config(page_title="Premieres A/B Test", layout="wide")

st.title("🎬 Premieres Week A/B Test Dashboard")

df = pd.read_csv("data/ab_data.csv")

control = df[df.group == "A"]
test = df[df.group == "B"]

# CTR
ctr_control = control.clicked.mean()
ctr_test = test.clicked.mean()

col1, col2 = st.columns(2)
col1.metric("CTR Control", f"{ctr_control:.2%}")
col2.metric("CTR Test", f"{ctr_test:.2%}", 
            f"{(ctr_test/ctr_control - 1)*100:.1f}% uplift")

# Z-test
z_stat, p_value = proportions_ztest(
    [control.clicked.sum(), test.clicked.sum()],
    [len(control), len(test)]
)

st.subheader("Statistical Test")
st.write(f"Z-statistic: {z_stat:.3f}")
st.write(f"P-value: {p_value:.5f}")

if p_value < 0.05:
    st.success("Result is statistically significant ✅")
else:
    st.warning("Result is NOT statistically significant")

# Visualization
st.subheader("CTR Comparison")

fig, ax = plt.subplots()
ax.bar(["Control", "Test"], [ctr_control, ctr_test])
ax.set_ylabel("CTR")
st.pyplot(fig)
