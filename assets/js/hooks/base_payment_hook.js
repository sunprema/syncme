import { encodeFunctionData, numberToHex} from 'viem'
import { ERC20ABI } from "./erc-20_abi";

const paymasterServiceUrl = "https://api.developer.coinbase.com/rpc/v1/base-sepolia/C4yrDOwWBAyXUVSpjI97Nntf1XIfmDbW"
const base_sepolia_usdc_address = "0x036CbD53842c5426634e7929541eC2318f3dCF7e"

export const BasePaymentHook = (sdkProvider) => ({    
    
    mounted(){

        this.handleEvent("booking_created", async( bookEvent_call_data) => {
            const {user_wallet_address, booking_id, to, data, price_at_booking} = bookEvent_call_data
            console.log(user_wallet_address, booking_id, to, data)

            approve_spending_call =  {
                    to: base_sepolia_usdc_address,
                    value: '0x0',
                    data: encodeFunctionData({
                        abi: ERC20ABI,
                        functionName: 'approve',
                        args: [to, price_at_booking]                        
                    })
            }

            bookingEvent_call = {
                to: to,
                data: data // Encode using your ABI                    
            }

            const calls =[
                approve_spending_call,
                //create_eventtype_call
                bookingEvent_call                    
            ]

            const sendCallsResponse = await sdkProvider.request({
                    method: 'wallet_sendCalls',
                    params: [{
                        version: '1.0',
                        chainId: numberToHex(base.constants.CHAIN_IDS.baseSepolia),
                        atomicRequired: true,
                        from: user_wallet_address,
                        calls: calls,
                        capabilities: {

                            paymasterService: {
                                url: paymasterServiceUrl
                            },
                            dataCallback:{
                                requests:[
                                    { 
                                        "type": "email" , 
                                        "optional" : false 
                                    },
                                    { 
                                        "type": "name" , 
                                        "optional" : false 
                                    }
                                ],                                
                            },  
                        }
                }]
            });
            window.bookEventResult = sendCallsResponse

            const checkStatus = async () => {
                const status = await sdkProvider.request({
                    method: 'wallet_getCallsStatus',
                    params: [sendCallsResponse.callsId]
                });
                window.bookingEventStatus = status
                if (status.status === 200 || status.status === "CONFIRMED") {
                    console.log('Batch completed successfully!');
                    console.log('Transaction receipts:', status.receipts);
                    const txHash = status.receipts[0]?.transactionHash;
                    const logs = status.receipts[0]?.logs;
                    console.log( txHash );
                    console.log(logs);
                    window.booking_event_logs = logs;

                    const email = sendCallsResponse?.capabilities?.dataCallback?.email 
                    const name = sendCallsResponse?.capabilities?.dataCallback?.name 
                        
                    this.pushEvent( "booking_txhash_event", {tx_hash: txHash , booking_id, email, name }, (reply, ref) =>  {
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
            
        })
       

        this.el.addEventListener("click" ,() =>{
            console.log("Will pay and confirm booking here");
            const { eventId, userWalletAddress, contractEventId} = this.el.dataset
            console.log(eventId, userWalletAddress, contractEventId)
            this.pushEvent("pay_and_confirm_booking")
            
        })
    }

})