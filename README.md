# REVERIE: An AO Content Vault

This project demonstrates a decentralized content gating mechanism using **Arweave's AO (Arweave Overlay)** for backend computation and a custom token for access. Users can mint tokens on the AO network via a simple frontend, which then grants them access to exclusive content.

---

## ✨ Features

* **AO Backend:** Leverages the AO computing environment for secure and scalable token management and content gating logic.
* **Custom Token:** Implements a custom token (e.g., "Content Access Token" or "CAT") that users mint to gain access.
* **Frontend Interface:** A clean, intuitive web interface built with HTML, CSS (**TailwindCSS**), and JavaScript for seamless user interaction.
* **Wallet Integration:** Connects securely using **ArConnect** for wallet management and transaction signing.
* **Dynamic UI:** Displays real-time token balance, token information (name, ticker, mint price), and provides a clear minting flow.
* **Gated Content:** Illustrates how content can be hidden or revealed based on a user's token ownership.

---

## 🚀 How It Works

1.  **Connect Wallet:** Users connect their Arweave wallet via ArConnect.
2.  **View Token Info:** The frontend fetches and displays details about the Content Access Token and its mint price.
3.  **Mint Tokens:** Users can mint tokens by sending a specified amount of AR to the AO vault process.
4.  **Access Content:** Once a user holds at least one token, the exclusive content becomes visible in the UI.

---

## 🛠️ Getting Started

Follow these steps to set up and run the project locally.

### Prerequisites

* Node.js and npm/yarn (for installing `ao-sdk` if needed for deployment script).
* **ArConnect** browser extension.
* An Arweave wallet with some AR for minting.

### Setup

1.  **Clone the Repository:**
    ```bash
    git clone [https://github.com/your-username/your-repo-name.git](https://github.com/your-username/your-repo-name.git)
    cd your-repo-name
    ```

2.  **Deploy the AO Vault Process:**
    * Ensure your `vault.lua` file is correctly configured (e.g., with initial `creator`, `mintPrice`, `name`, `ticker`).
    * Deploy your `vault.lua` process to AO. This will give you a unique **Process ID**.
    * *Example deployment command (using `aos` CLI or similar):*
        ```bash
        aos deploy vault.lua
        ```
    * **Keep track of the deployed Process ID.**

3.  **Configure the Frontend:**
    * Open `index.html` in a text editor.
    * Locate the `state` object in the JavaScript section.
    * Update the `processId` field with the Process ID obtained from your AO vault deployment:
        ```javascript
        const state = {
            // ... other state properties
            processId: "YOUR_DEPLOYED_VAULT_PROCESS_ID", // <--- UPDATE THIS
            // ...
        };
        ```
    * *(Optional)* If you have a separate token process for a `aoTokenProcessId` (like a PNTS token), update that too.

4.  **Open the Frontend:**
    * Simply open the `index.html` file in your web browser (e.g., `file:///path/to/your/project/index.html`).

---

## 🚀 Usage

1.  **Connect Wallet:** Click the "Connect Wallet" button and approve the connection in ArConnect.
2.  **View Details:** Your wallet address, token balance, and token details (Name, Ticker, Mint Price) should appear.
3.  **Mint Tokens:** Click the "Mint 1 Token" button. Approve the transaction in ArConnect.
4.  **Access Content:** Once the minting transaction is confirmed on AO and your balance updates, the gated content will become visible.

---

## 🤝 Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

---

## 📄 License

This project is open-sourced under the MIT License.