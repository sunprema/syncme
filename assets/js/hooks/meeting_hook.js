import { SyncMeABI } from "./syncme_abi";

const paymasterServiceUrl = "https://api.developer.coinbase.com/rpc/v1/base-sepolia/C4yrDOwWBAyXUVSpjI97Nntf1XIfmDbW"


export const MeetingHook = (sdkProvider) => ({

    mounted(){

        this.handleEvent("onchain_complete_meeting", async( completeMeeting_call_data )=> {
            const {user_wallet_address, booking_id, to, data,} = completeMeeting_call_data
            let completeBooking_call
        })

        this.el.addEventListener("click", () => {

            this.pushEvent("complete_booking")

        });

    }

});