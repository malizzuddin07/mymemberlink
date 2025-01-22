<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dummy Payment Website</title>
    <link rel="stylesheet" href="styles.css">
</head>

<body>
    <div class="payment-container">
        <h1>Payment Page</h1>
        <form id="payment-form">
            <div class="form-group">
                <label for="card-number">Card Number</label>
                <input type="text" id="card-number" placeholder="Enter card number" required>
            </div>

            <div class="form-group">
                <label for="expiry-date">Expiry Date</label>
                <input type="text" id="expiry-date" placeholder="MM/YY" required>
            </div>

            <div class="form-group">
                <label for="cvv">CVV</label>
                <input type="text" id="cvv" placeholder="Enter CVV" required>
            </div>

            <div class="form-group">
                <p><strong>Amount to Pay:</strong> <span id="amount-display">RM19.99</span></p>
            </div>

            <button type="submit" class="btn">Pay Now</button>
            <button type="button" id="simulate-cancel" class="btn btn-cancel">Simulate Cancel</button>
            <button type="button" id="simulate-fail" class="btn btn-fail">Simulate Failed Payment</button>
        </form>
        <div class="success-message" id="success-message" style="display: none;">
            Payment Successful! 🎉
        </div>
    </div>

    <script>
        // Ensure required variables are defined
        const urlParams = new URLSearchParams(window.location.search);
        const amount = urlParams.get('amount') || 19.99; // Default to 19.99 if not provided
        const userId = urlParams.get('user_id') || 4;    // Default to user ID 4 if not provided

        // Update the amount display
        document.getElementById('amount-display').textContent = `RM${amount}`;

        // Function to handle payment actions
        async function handlePaymentAction(status) {
            try {
                const paymentData = {
                    amount: amount,
                    userId: userId,
                    status: status,
                };


                const response = await fetch('process_payment.php', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify(paymentData),
                });

                const result = await response.json();

                // Display the response message
                const successMessage = document.getElementById('success-message');
                successMessage.textContent = result.message;
                successMessage.style.display = 'block';
            } catch (error) {
                console.error('Error:', error);
            }
        }

        // Event Listeners for Buttons
        document.getElementById('simulate-cancel').addEventListener('click', () => {
            handlePaymentAction('Pending');
        });

        document.getElementById('simulate-fail').addEventListener('click', () => {
            handlePaymentAction('Failed');
        });

        document.getElementById('payment-form').addEventListener('submit', (event) => {
            event.preventDefault();
            handlePaymentAction('Paid');
        });
    </script>
</body>

</html>