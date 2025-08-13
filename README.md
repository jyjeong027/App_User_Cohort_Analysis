# Project Overview
This project analyzes customer behavior by examining app engagement and purchase conversion using cohort analysis through SQL. 

# Background 
Company A is a grocery and non-grocery retailer (home & lifestyle products) that delivers weekly personalized promotions through its loyalty app.  
Despite opening the app, **approximately 15% of users do not complete a purchase in the same week**. 

# Business Objective and Problem Definition :
**Objective**: Understand why a subset of users open the app but do not make purchases, and determine whether efforts should be made to convert them into active shoppers.

**Key Questions**:
-	Why do these customers open the app but not shop?
-	Should efforts be made to decrease this gap? If so, what strategies can be implemented?

# Methodology 
**Customer Cohort Definition** 
- App_Opened_Only Customers 
- App_Opened + Purchased Customers

**SQL Code in Repository**
Modules:
- 01_customer_group_segmentation.sql — Create customer cohorts
- 02_shopping_frequency_analysis.sql — Analyze purchase frequency and app usage
- 03_category_exclusivity_analysis.sql — Measure category-level exclusivity
- 04_cross_shopping_behavior.sql — Identify cross-retailer shoppers via credit card data

**Timeframes Analyzed:**
- Compared across for multiple periods/timeframe to ensure consistency in behavior 
  - Past 1 Month (e.g., August)
  - 3 distinct months (e.g., March, June, December)
  - Past 52 Weeks

# Hypotheses Testing and Findings 
1.	**Customers have longer shopping cycles**
- **Metrics:** Average trips/spend/app opens per period  
- **Code Code:** `02_shopping_frequency_analysis.sql`  
- **Results:** `App_Opened_Only` customers shop **3× less frequently** and spend **2× less** than `App_Opened + Purchased` customers.  
- **Conclusion:** Shopping frequency contributes to the gap, but does not fully explain it.

2.	**Non-grocery exclusivity - home & lifestyle product purchasers who naturally have longer purchase cycles.**
- **Metrics:** % of customers exclusively shopping home & lifestyle products
- **Code Module:** `03_category_exclusivity_analysis.sql`  
- **Results:** Only **2%** of `App_Opened_Only` customers are exclusive to home & lifestyle purchasers
- **Conclusion:** Category exclusivity is **not a major driver** of the conversion gap.

3.	**Multi-retailer shoppers: Some regularly shop across multiple retailers**
- **Metrics:** % of customers shopping exclusively at Company A vs across multiple retailers  
- **Code Module:** `04_cross_shopping_behavior.sql`  
- **Results:** Over **70%** of `App_Opened_Only` customers regularly shop with competitors and spend less at Company A.  
- **Conclusion:** The **primary driver** of the 15% conversion gap is **multi-retailer behavior**.

# Conclusion 
The analysis suggests that the gap between app opening and purchase activity is primarily driven by customers who shop across multiple retailers.

**Strategic Recommendation:**  
Therefore, Company A should focus on increasing loyalty and reducing multiple retailer shopping by offering: 
- Provide better personalized promotions to attract these multi retailer shopping customers
- Enhance private brand offerings to differentiate Company A from competitors, giving customers a unique reason to shop at Company A over other retailers.
