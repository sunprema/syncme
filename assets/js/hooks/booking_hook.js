import { requestSpendPermission } from "@base-org/account/spend-permission";
import { encodeFunctionData, numberToHex} from 'viem'
import { SyncMeABI } from "./syncme_abi";
import { ERC20ABI } from "./erc-20_abi";



const provider = window.createBaseAccountSDK({
          appName: "SyncMe.link",
          appLogoUrl: "https://base.org/logo.png",
          appChainIds: [84532]
    }).getProvider();

const my_addess = "0x652574636c202993d19f99a9a5bac9833787f74b"    
const syncme_contract = "0xCc8233726f4520b74766dEa8681d2a2f4789FFFA"
const paymasterServiceUrl = "https://api.developer.coinbase.com/rpc/v1/base-sepolia/C4yrDOwWBAyXUVSpjI97Nntf1XIfmDbW"
const base_sepolia_usdc_address = "0x036CbD53842c5426634e7929541eC2318f3dCF7e"

export const BasePaymentHook = (sdkProvider) => ({    
    
    mounted(){

        const payAndBookEvent = async () => {
            try {
                if (!window.createBaseAccountSDK) {
                  this.pushEvent("base-sign-in-error", { error: "Base SDK not loaded" });
                  return;
                }
                const nonce = crypto.randomUUID().replace(/-/g, "");
        
                const { accounts, chainId, isConnected } = await provider.request({
                  method: "wallet_connect",
                  params: [
                    {
                        version: "1",
                        capabilities: {
                            signInWithEthereum: {
                                nonce,
                                chainId: "0x14a34",// "0x2105", // Base Mainnet (8453)
                            },
                        },
                    }
                  ],
                });

                const { address } = accounts[0];
                const { message, signature } = accounts[0].capabilities.signInWithEthereum;
                
                const booking_call_data = encodeFunctionData({
                    abi: SyncMeABI,
                    functionName: 'createEventType',
                    args: ["Master Solidity", "Master Solidity", "In this meeting, lets discuss about mastering Solidity", 60, 500_000]
                });

                console.log(booking_call_data);
                
                
                //request spend permission
                approve_spending_call =  {
                    to: base_sepolia_usdc_address,
                    value: '0x0',
                    data: encodeFunctionData({
                        abi: ERC20ABI,
                        functionName: 'approve',
                        args: [syncme_contract, 10_000_000]
                    })
                }

                create_eventtype_call = {
                        to: syncme_contract,
                        data: booking_call_data // Encode using your ABI                    
                }
            
                create_booking_call = {
                    to: syncme_contract,
                    data: encodeFunctionData({
                        abi: SyncMeABI,
                        functionName: 'bookEvent',
                        args: [4, 1763062907]
                    })
                }
                const calls =[
                    approve_spending_call,
                    //create_eventtype_call
                    create_booking_call                    
                ]

                // Send the transaction with paymaster capabilities
                const result = await provider.request({
                    method: 'wallet_sendCalls',
                    params: [{
                        version: '1.0',
                        chainId: numberToHex(base.constants.CHAIN_IDS.baseSepolia),
                        atomicRequired: true,
                        from: address,
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
                                ]
                            },  
                        }
                }]
                });

                this.pushEvent("save_booking", {txhash: result});

                window.provider = provider
                window.result = result
                console.log("the result is ", result)
            }
            catch (error) {
                console.log(error);
                    this.pushEvent("base-sign-in-error", { error: error?.message || String(error) });
            }
        }

        this.el.addEventListener("click" ,() =>{
            console.log("Will process payment here");
            payAndBookEvent();
        })
    }

})