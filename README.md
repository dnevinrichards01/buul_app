### Welcome to Buul's iOS Frontend

*For details and a tutorial, visit [Buul's backend repo](https://github.com/dnevinrichards01/buul_backend/tree/try_it_out_local) which is serving as the Buul project's 'hub'.*

### A quick taste of the interactive portfolio graph
Here are two images taken from demo in the [backend repo](https://github.com/dnevinrichards01/buul_backend/tree/try_it_out_local)'s README.md file:


<img width="299" height="598" alt="Screenshot 2025-12-31 at 11 34 38 PM" src="https://github.com/user-attachments/assets/6930e75f-3537-4938-8e46-90a5db11b72d" />
<img width="292" height="600" alt="Screenshot 2025-12-31 at 11 35 33 PM" src="https://github.com/user-attachments/assets/9d564931-a275-49fa-bf3b-e1014df1fc67" />


### About

#### Buul is a personal finance app that:
1. automatically invests and maximizes your credit-card cashback
2. converts spending into compound interest
3. is tackling the retirement crisis

#### Frontend Tech Stack
1. SwiftUI for UI and networking
2. CoreData to store portfolio graph data
3. Associated Domain to enable:
    - Universal Links to redirect back to app (OAuth flows)
    - Web Credentials to allow password autofill

#### Key Features:
1. Real-time portfolio graph
2. Plaid Integration to connect to your bank account and automatically detect cashback
3. DIY Robinhood brokerage integration built with Postman and robinstocks library
4. Email-based OTP to verify identity before changing account information



#### Some Files / Landmarks of Interest:
##### 1. Communication with backend
- `buul_app/Services/ServerCommunicator.swift` 
##### 2. Refresh and create the portfolio graph
- `buul_app/Services/GraphUtils.swift`
- `buul_app/Views/Home/HomeView.swift`
- `buul_app/Views/Home/HomeStocksView.swift`
- `buul_app/Views/Home/StockGraphView.swift` 
##### 3. Plaid integration
- `buul_app/Views/Plaid/PlaidLinkManager.swift`
- `buul_app/Views/Plaid/LinkView.swift` 
##### 4. Page / Navigation Structure
- `buul_app/Views/Landing/Buul`
