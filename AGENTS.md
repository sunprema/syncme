# Project: SyncMe.link

This document outlines the core mission, architecture, and principles for the SyncMe.link project. It serves as a foundational context for AI assistants and team members.


## 1. Core Mission & Vision

**One-Liner:** The trustless scheduling and payment platform for the Web3 economy.

**Vision:** To empower professionals, creators, and consultants to monetize their time seamlessly and globally, eliminating the friction and risk of traditional payment and scheduling systems. We are building the native scheduling layer for the internet of value.

## 2. The Core Problem

We are solving the pain points for "Alice," a Web3 professional:
1.  **Scheduling Inefficiency:** DMs and emails are flooded with meeting requests, making it hard to separate serious inquiries from noise.
2.  **Payment Risk:** Asking for payment upfront creates friction and lacks professionalism. The payer has no guarantee the host will show up, and the host has no guarantee of payment if they don't ask for it upfront.
3.  **Cross-Border Friction:** Traditional payment processors like Stripe and PayPal have high fees, delays, and regional limitations for international clients.
4.  **Fragmented Tooling:** Users are forced to duct-tape Calendly (scheduling) with manual wallet transfers (risky and unprofessional).

## 3. The Solution

SyncMe.link is a Web2/Web3 hybrid application that combines a user-friendly scheduling interface with an on-chain escrow smart contract on the Base L2 network.
This is the offchain part of the project.

**Core Features:**
*   **One-Link Profile:** Hosts connect their wallet and Google Calendar to create a public booking page with various paid event types.
*   **Trustless Escrow:** Client payments (in USDC) are automatically locked in a secure smart contract when a meeting is booked.
*   **Proof-of-Attendance:** A simple off-chain OTP (One-Time Password) is exchanged during the meeting to cryptographically prove attendance and trigger the instant release of funds from the escrow.
*   **On-Chain Affiliate Protocol:** A permissionless, on-chain referral system allows anyone to earn a commission for promoting a host's booking page, with instant, trustless payouts managed by the smart contract.

## 4. Key Personas

*   **The Host (Alice):** The professional, consultant, or creator who wants to get paid for their time. They set up the profile and event types.
*   **The Client (Bob):** The person who wants to book a meeting with the Host. They visit the Host's page and pay for a time slot.
*   **The Affiliate (Charlie):** Anyone who promotes a Host's link to earn a commission.

## 5. Core User Journeys

### 5.1. Host Onboarding (Alice)
1.  Alice lands on `syncme.link` and clicks "Connect Wallet".
2.  A JS Hook triggers the Base Smart Wallet SDK (Privy). Alice signs in with her email/socials, accessing her embedded smart wallet.
3.  The frontend sends her wallet address to the Phoenix LiveView backend, which logs her in or creates her account.
4.  Alice is prompted to connect her Google Calendar via a standard server-side OAuth 2.0 flow.
5.  Alice creates her first Event Type: title, duration, price (USDC), and a default affiliate fee %.

### 5.2. Client Booking (Bob)
1.  Bob visits `syncme.link/alice`.
2.  The Phoenix LiveView backend fetches Alice's availability from her Google Calendar in real-time.
3.  Bob selects an event type, a date, and a time slot. The UI updates interactively via LiveView.
4.  Bob clicks "Book and Pay".
5.  A JS Hook triggers the Base SDK. Bob must approve the USDC transfer to our `MeetingEscrow.sol` contract. He only signs one transaction. Gas can be sponsored.
6.  The JS Hook sends the `txHash` back to the LiveView backend.
7.  An Oban background job on the server monitors the Base L2 network for the transaction confirmation.

### 5.3. Meeting & Payout
1.  Once the transaction is confirmed, the backend updates the booking status to `confirmed`.
2.  The backend uses Alice's Google tokens to create the calendar event and generate a Google Meet link.
3.  Confirmation emails are sent. Alice's email contains a link to her dashboard. Bob's email contains the meeting link and the **OTP**.
4.  At the start of the meeting, Bob shares the OTP with Alice.
5.  Alice enters the OTP into her SyncMe.link dashboard.
6.  The backend verifies the OTP and calls `completeBooking()` on the smart contract using its trusted relayer wallet.
7.  The smart contract atomically releases the funds to Alice, the platform, and the affiliate (if any).

## 6. Technical Architecture

*   **Backend:** Elixir v1.15+ with the Phoenix Framework v1.7+ (specifically using LiveView).
*   **Database:** PostgreSQL v14+.
*   **Background Jobs:** Oban for reliable, database-backed background jobs (especially for blockchain monitoring).
*   **Frontend:** Primarily server-rendered Phoenix LiveView. Minimal client-side JavaScript managed via Phoenix JS Hooks for Web3 wallet interactions.
*   **Blockchain:** Base Layer 2 network.
*   **Smart Contract:** Solidity v0.8.20+, leveraging OpenZeppelin v5.0+ for security (`Ownable`, `Pausable`, `ReentrancyGuard`). The contract is named `MeetingEscrow.sol`.
*   **External APIs:**
    *   Google Cloud Platform for Google Calendar & Meet APIs.
    *   A blockchain node provider (e.g., Alchemy, Infura) for RPC access to the Base network.
    *   Base Smart Wallet SDK (powered by Privy) for user onboarding and embedded wallets.

## 7. Business Model & GTM

*   **Monetization:** A non-negotiable **5% platform fee** (500 Bps) on the total transaction value of every completed meeting.
*   **Go-to-Market:** A product-led growth strategy centered around the **On-Chain Affiliate Protocol**.
    *   **Phase 1:** White-glove onboarding of 100 influential Web3 figures.
    *   **Phase 2:** Leverage the affiliate protocol to let their followers become our salesforce.

## 8. Core Principles & Philosophy

*   **UX over Dogma:** The user experience must be as simple and intuitive as the best Web2 applications. We will abstract away blockchain complexity (e.g., gas fees, seed phrases) wherever possible.
*   **Security is Non-Negotiable:** All smart contracts must be professionally audited. All sensitive off-chain data (like Google tokens) must be encrypted at rest. We prioritize user safety above all else.
*   **Trustless by Default:** The core value exchange must be managed by the smart contract, not by us as a trusted intermediary. We build trust by making ourselves unnecessary in the transaction.
*   **Pragmatic Decentralization:** We will use a centralized backend for performance, user experience, and integrations (like Google Calendar). We will use a decentralized smart contract for the most critical component: the custody and transfer of user funds.

## 9. Tech Stack
* **Full stack framework** Elixir, Phoenix LiveView, Oban, Postgres for database, Elixir Ecto, tailwindcss.
* **Block chain** Etherium, Solidity, view, hardhat.
* **Etherium Layer 2 metwork** We will use base from https://docs.base.org/base-account/quickstart/web


