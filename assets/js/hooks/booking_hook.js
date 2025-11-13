import { encodeFunctionData, numberToHex} from 'viem';


const paymasterServiceUrl = "https://api.developer.coinbase.com/rpc/v1/base-sepolia/C4yrDOwWBAyXUVSpjI97Nntf1XIfmDbW"


export const BookingHook = (sdkProvider) => ({ 

    mounted(){

        this.handleEvent("complete_booking_chain", async ( booking_complete_call_data) => {
            const {partner_wallet_address, booking_id, to, data } = booking_complete_call_data
            console.log(JSON.stringify(booking_complete_call_data));

            const complete_booking_call = {
                to: to,
                data: data
            }

            const calls = [ complete_booking_call ];

            const sendCallsResponse = await sdkProvider.request({
                method: 'wallet_sendCalls',
                    params: [{
                        version: '1.0',
                        chainId: numberToHex(base.constants.CHAIN_IDS.baseSepolia),
                        from: partner_wallet_address,
                        calls: calls, 
                        capabilities: {
                            paymasterService: {
                                url: paymasterServiceUrl
                            },
                        }
                    }]
            })
            window.completeBookingResult = sendCallsResponse

            const checkStatus = async () => {
                const status = await sdkProvider.request({
                    method: 'wallet_getCallsStatus',
                    params: [sendCallsResponse]
                });
                window.completeBookingStatus = status
                if (status.status === 200 || status.status === "CONFIRMED") {
                    console.log('Batch completed successfully!');
                    console.log('Transaction receipts:', status.receipts);
                    const txHash = status.receipts[0]?.transactionHash;
                    const logs = status.receipts[0]?.logs;
                    console.log( txHash );
                    console.log(logs);
                    window.complete_booking_logs = logs;

                    this.pushEvent( "complete_booking_txhash_event", {tx_hash: txHash , booking_id }, (reply, ref) =>  {
                        window.respy = reply
                    } );
                     

                } else if (status.status === 100 || status.status === "PENDING") {
                    console.log('Batch still pending...');
                    setTimeout(checkStatus, 2000); // Check again in 2 seconds
                } else {
                    console.error('Batch failed with status:', status.status);
                }
            };
            checkStatus();
            
        });

        

        this.el.addEventListener("click", () =>{
            alert("Booking will be completed here");
            const bookingId = this.el.dataset.bookingId
            this.pushEvent( "complete_booking", {booking_id: bookingId});
        });
    }
    
});