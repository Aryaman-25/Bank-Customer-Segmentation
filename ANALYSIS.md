# Analysis Report: Bank Customer Segmentation

## Business Question

**Which customer segments drive the most value for the bank, and how should marketing/retention strategy differ across them?**

## Methodology Summary

- **~1.05M raw transactions** loaded and cleaned in MySQL (malformed dates handled via regex validation, missing gender/location defaulted to "Unknown" rather than dropped, implausible DOBs excluded from age calculation).
- Data aggregated to **98,242 unique customers** (from a random 100K-customer sample of the full cleaned customer base) with Recency, Frequency, and Monetary value calculated per customer.
- Each customer scored 1–5 on R, F, and M using quintiles, summed into an RFM Total, then mapped to five segments: **Champions, Loyal Customers, Potential Loyalists, At Risk, Dormant/Lost.**

---

## Sub-Question 1: Who are our customers?

- **Gender:** 72.9% Male, 27.0% Female, 0.09% Unknown (missing in source data)
- **Age:** average ~40 years old, range 5–76 (9.6% of customers have missing/unparseable date of birth and are excluded from age-based cuts)
- **Geography:** highly concentrated in major metros — Mumbai (9,762 customers), New Delhi (8,020), Bangalore (7,565), Gurgaon (6,978), and Delhi (6,747) together account for a large share of the customer base, across 4,035 unique locations total (long tail of smaller towns/cities)

**Takeaway:** the customer base skews male, middle-aged, and urban-metro-concentrated — useful context for any targeted campaign design.

## Sub-Question 2: What does spending behavior look like?

- **Transaction frequency:** 98.3% of customers show exactly 1 transaction in the observed window; only 1.7% show 2, and 0.02% show 3. This is a direct consequence of the dataset spanning only ~3 months (Aug 1 – Oct 21, 2016) — not necessarily true single-purchase behavior over a customer's full relationship with the bank.
- **Transaction amount (Monetary):** highly skewed — median transaction ₹442, but mean ₹1,582, driven by a long tail of high-value transactions (max ₹720,001).
- **Account balance:** also highly skewed — median ₹16,957, mean ₹117,118, reflecting a small number of very high-balance customers.
- **Recency:** average 55 days since last transaction, but bimodal — a cluster of very recent customers and a cluster near the 80-day (end of window) mark.

**Takeaway:** the customer base is dominated by low-frequency, low-to-mid transaction value activity, with a small number of high-value outliers pulling averages upward. Median, not mean, is the more honest summary statistic here.

## Sub-Question 3: Which segments exist?

| Segment | Customers | % of Customers | Revenue (₹) | % of Revenue | Avg Revenue/Customer (₹) | Avg Recency (days) |
|---|---|---|---|---|---|---|
| Champions | 1,076 | 1.10% | 4,231,423 | 2.72% | 3,933 | 29.0 |
| Loyal Customers | 13,501 | 13.74% | 60,903,006 | 39.19% | **4,511** | 24.0 |
| Potential Loyalists | 48,961 | 49.84% | 81,877,818 | 52.69% | 1,672 | 49.8 |
| At Risk | 31,806 | 32.38% | 8,225,875 | 5.29% | 259 | 74.1 |
| Dormant/Lost | 2,898 | 2.95% | 158,035 | 0.10% | 55 | 81.0 |

**Notable finding:** Loyal Customers have the *highest* average revenue per customer — even above Champions. This is a direct effect of Frequency barely varying across the dataset (see Limitations); the segmentation is effectively being driven by Recency and Monetary rather than a true frequency signal. This is disclosed transparently rather than presented as a clean textbook RFM result.

## Sub-Question 4: Which segment is most valuable, and which is most at-risk?

- **Most valuable (highest per-customer value): Loyal Customers** — only 13.7% of customers but 39.2% of revenue, with the best average revenue per customer of any segment. This is the segment retention spend should protect first — losing them has the largest revenue impact per customer lost.
- **Largest opportunity: Potential Loyalists** — the single biggest segment (49.8% of customers) and already the single biggest revenue contributor (52.7%). Converting even a modest share of this group into repeat, high-frequency customers would be the highest-leverage move available, given its sheer size.
- **Most at-risk: At Risk segment** — 32.4% of customers but only 5.3% of revenue, with recency averaging 74 days (near the edge of the observed window) — low engagement, low value, minimal loss if unaddressed but a candidate for low-cost reactivation (email/SMS) rather than high-touch retention spend.
- **Effectively unrecoverable: Dormant/Lost** — 2.95% of customers, 0.10% of revenue. Not worth retention investment.

## Sub-Question 5: Are there regional or demographic patterns worth targeting?

**By age band:**

| Age Band | At Risk % | Loyal % | Potential Loyalists % |
|---|---|---|---|
| <25 | 24.1% | 18.1% | 56.6% |
| 25–35 | 40.4% | 8.3% | 46.2% |
| 35–45 | 32.9% | 12.9% | 50.1% |
| 45–55 | 23.9% | 18.6% | 54.0% |
| 55+ | 24.0% | 20.7% | 50.8% |

**25–35 year-olds are the weakest-performing age band** — the highest At Risk share (40.4%) and lowest Loyal share (8.3%) of any group. This is a candidate for targeted re-engagement (this age group may be highly price-sensitive or have competing banking relationships). Conversely, **under-25 and 55+ customers convert to Loyal status at nearly 2.5x the rate of 25–35 year-olds.**

**By city (top 6 by customer count):**

| City | At Risk % | Loyal % |
|---|---|---|
| Mumbai | 28.3% | 16.6% |
| New Delhi | 29.8% | 16.4% |
| Gurgaon | 32.3% | 13.4% |
| Delhi | 32.2% | 13.6% |
| Noida | 32.0% | 13.2% |
| Bangalore | 34.2% | 12.8% |

Mumbai and New Delhi show the healthiest segment mix (more Loyal, less At Risk) of the major metros; Bangalore shows the weakest mix among top cities.

---

## Business Recommendations

1. **Protect the Loyal Customers segment first.** They're only 13.7% of the base but deliver the highest per-customer value. A targeted relationship-banking or loyalty-perks program here has the best revenue-per-rupee-spent defense.
2. **Prioritize converting Potential Loyalists.** This is the largest and second-most-valuable segment — a repeat-engagement campaign (e.g., second-transaction incentives, targeted offers) aimed at this half of the customer base has the highest total upside given its size.
3. **Use low-cost channels for At Risk customers**, not high-touch retention spend — their revenue contribution doesn't justify expensive intervention.
4. **Target the 25–35 age band specifically** — this segment underperforms every other age band and represents a real, named gap rather than a diffuse "engage more" strategy.
5. **Re-run this analysis on a longer transaction window (12+ months) before making frequency-based decisions** — the current 3-month window limits how much Frequency can meaningfully differentiate customers.

---

## Limitations & Notes on Data Quality

- **Short observation window (~3 months):** Frequency is compressed (98.3% of customers = 1 transaction), so this RFM segmentation leans more heavily on Recency and Monetary. Treat "Champions" and "Loyal Customers" labels as directionally useful but not a mature frequency-based loyalty signal.
- **Sampling:** Analysis and dashboard built on a random 100K-customer sample (98,242 after cleaning) of the full ~880K+ unique customer base, for performance reasons on standard hardware. Full cleaning and RFM base calculation was done on the complete dataset in MySQL before sampling — only the scoring/visualization layer is sampled.
- **Missing data:** ~9.6% of customers have no usable DOB (excluded from age analysis, not from revenue analysis); ~0.09% missing gender (labeled "Unknown", retained).
- **Minor row-count discrepancy on load:** raw import returned ~91 more rows than the source file's line count, likely due to unescaped delimiters/newlines within a small number of location fields during CSV parsing. This affects <0.01% of records and does not materially change the analysis.
