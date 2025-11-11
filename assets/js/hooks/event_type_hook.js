import { encodeFunctionData, numberToHex, parseEventLogs } from 'viem'

const paymasterServiceUrl = "https://api.developer.coinbase.com/rpc/v1/base-sepolia/C4yrDOwWBAyXUVSpjI97Nntf1XIfmDbW"
export const EventTypeHook = (sdkProvider) => ({
    
    mounted(){

        this.handleEvent("event_created", async (create_event_call_data) => {     
           const {partner_wallet_address, to, data, event_type_id} = create_event_call_data
           const calls = [{ to, data }]

           const callsId = await sdkProvider.request({
                                method: 'wallet_sendCalls',
                                params: [{
                                    version: '1.0',
                                    chainId: numberToHex(base.constants.CHAIN_IDS.baseSepolia),
                                    from: partner_wallet_address,
                                    calls: calls,
                                    capabilities: {           
                                       paymasterService: {
                                           url: paymasterServiceUrl
                                        }
                                    }
                                }] 
            });

            // Poll for status updates
            const checkStatus = async () => {
                const status = await sdkProvider.request({
                    method: 'wallet_getCallsStatus',
                    params: [callsId]
                });
            
                if (status.status === 200 || status.status === "CONFIRMED") {
                    console.log('Batch completed successfully!');
                    console.log('Transaction receipts:', status.receipts);
                    const txHash = status.receipts[0]?.transactionHash;
                    const logs = status.receipts[0]?.logs;
                    
                    console.log( txHash );
                    console.log(logs);
                    window.event_logs = logs;
                    this.pushEventTo( this.el, "txhash_event", {txHash , event_type_id}, (reply, ref) =>  {
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
    }

});