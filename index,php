<?php
// Must be FIRST line - no space before <?php
header('Content-Type: application/json');

// Turn off error display in production
ini_set('display_errors', 0);
error_reporting(0);

$action = $_GET['action'] ?? $_POST['action'] ?? '';

// Database connection (CHANGE THESE VALUES!)
$host = 'localhost';
$db   = 'math_blitz';
$user = 'root';           // ← your real username
$pass = '';               // ← your real password

try {
    $pdo = new PDO("mysql:host=$host;dbname=$db;charset=utf8mb4", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    http_response_code(500);
    die(json_encode(['error' => 'Database connection failed']));
}

switch ($action) {
    case 'register':
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            http_response_code(405);
            die(json_encode(['error' => 'Method not allowed']));
        }

        $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
        $username = trim($input['username'] ?? '');
        $password = $input['password'] ?? '';

        if (empty($username) || strlen($username) < 3 || strlen($username) > 50) {
            http_response_code(400);
            die(json_encode(['error' => 'Username must be 3–50 characters']));
        }
        if (strlen($password) < 8) {
            http_response_code(400);
            die(json_encode(['error' => 'Password must be at least 8 characters']));
        }

        // Check if username exists
        $stmt = $pdo->prepare("SELECT id FROM users WHERE username = ?");
        $stmt->execute([$username]);
        if ($stmt->fetch()) {
            http_response_code(409);
            die(json_encode(['error' => 'Username already taken']));
        }

        // Secure hash (Argon2id is strong & modern)
        $hash = password_hash($password, PASSWORD_ARGON2ID);

        $stmt = $pdo->prepare("INSERT INTO users (username, password) VALUES (?, ?)");
        $stmt->execute([$username, $hash]);

        echo json_encode(['success' => true, 'message' => 'Account created']);
        break;

    case 'login':
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            http_response_code(405);
            die(json_encode(['error' => 'Method not allowed']));
        }

        $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
        $username = trim($input['username'] ?? '');
        $password = $input['password'] ?? '';

        $stmt = $pdo->prepare("SELECT id, password FROM users WHERE username = ?");
        $stmt->execute([$username]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$user || !password_verify($password, $user['password'])) {
            http_response_code(401);
            die(json_encode(['error' => 'Invalid username or password']));
        }

        echo json_encode([
            'success' => true,
            'user' => [
                'id'       => (int)$user['id'],
                'username' => $username
            ]
        ]);
        break;

    case 'save-game':
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            http_response_code(405);
            die(json_encode(['error' => 'Method not allowed']));
        }

        $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;

        $required = ['user_id', 'difficulty', 'score', 'accuracy', 'time_result', 'correct', 'wrong', 'rank'];
        foreach ($required as $field) {
            if (!isset($input[$field]) || $input[$field] === '') {
                http_response_code(400);
                die(json_encode(['error' => "Missing or empty field: $field"]));
            }
        }

        $stmt = $pdo->prepare("
            INSERT INTO game_results 
            (user_id, difficulty, score, accuracy, time_result, correct, wrong, `rank`)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ");

        $stmt->execute([
            (int)$input['user_id'],
            $input['difficulty'],
            (int)$input['score'],
            (int)$input['accuracy'],
            (int)$input['time_result'],
            (int)$input['correct'],
            (int)$input['wrong'],
            $input['rank']
        ]);

        echo json_encode(['success' => true, 'message' => 'Game saved']);
        break;

    case 'stats':
        $user_id = (int)($_GET['user_id'] ?? 0);
        if ($user_id < 1) {
            http_response_code(400);
            die(json_encode(['error' => 'Invalid or missing user_id']));
        }

        $stmt = $pdo->prepare("
            SELECT 
                COUNT(*) AS total_games,
                COALESCE(MAX(score), 0) AS high_score,
                COALESCE(ROUND(AVG(accuracy), 0), 0) AS avg_accuracy,
                COALESCE((
                    SELECT `rank` 
                    FROM game_results 
                    WHERE user_id = ? 
                    ORDER BY FIELD(`rank`, 'S','A','B','C','D','F') 
                    LIMIT 1
                ), '-') AS best_rank
            FROM game_results 
            WHERE user_id = ?
        ");
        $stmt->execute([$user_id, $user_id]);
        $stats = $stmt->fetch(PDO::FETCH_ASSOC) ?: [];

        echo json_encode($stats);
        break;

        case 'leaderboard':
    // Get top 10 scores (you can change LIMIT 10 to whatever you want)
    $stmt = $pdo->prepare("
        SELECT 
            u.username,
            g.difficulty,
            g.time_result,
            g.score
        FROM game_results g
        JOIN users u ON g.user_id = u.id
        ORDER BY g.score DESC
        LIMIT 10
    ");
    $stmt->execute();
    
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Return clean JSON array
    echo json_encode($results);
    break;


    default:
        http_response_code(400);
        echo json_encode(['error' => 'Invalid action']);
        exit;
}   

exit;
?>
