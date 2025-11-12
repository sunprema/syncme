
const paymasterServiceUrl = "https://api.developer.coinbase.com/rpc/v1/base-sepolia/C4yrDOwWBAyXUVSpjI97Nntf1XIfmDbW"


export const BookingHook = (sdkProvider) => ({ 

    mounted(){
        this.el.addEventListener("click", () =>{
            alert("Booking will be completed here");
            const bookingId = this.el.dataset.bookingId
            this.pushEvent( "complete_booking", {booking_id: bookingId}, (reply,ref) => {
                console.log(JSON.stringify(reply));
            });
        });
    }
    
});