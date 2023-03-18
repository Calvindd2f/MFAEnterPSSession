const {Twilio} = require('twilio');

module.exports = async function (context, req) {
    const accountSid = process.env.TWILIO_ACCOUNT_SID;
    const authToken = process.env.TWILIO_AUTH_TOKEN;
    const twilioPhone = process.env.TWILIO_PHONE_NUMBER;
    const recipientPhone = process.env.RECIPIENT_PHONE_NUMBER;

    const twilioClient = new Twilio(accountSid, authToken);

    const otp = generateOTP();

    try {
        const message = await twilioClient.messages.create({
            body: `Your OTP is: ${otp}`,
            from: twilioPhone,
            to: recipientPhone
        });

        context.res = {
            status: 200,
            body: {otp}
        };
    } catch (error) {
        context.res = {
            status: 500,
            body: `Error sending OTP: ${error.message}`
        };
    }
};

function generateOTP() {
    return Math.floor(100000 + Math.random() * 900000);
}
