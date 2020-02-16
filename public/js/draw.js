// モード
let Mode = {
    pen: 0, // ペン
    eraser: 1, // 消しゴム
};

// ペンの色
let Color = {
    deepRed:     [193, 39, 45],
    red:         [255, 0, 0],
    salmonPink:  [237, 30, 121],
    hotPink:     [255, 105, 180],
    pink:        [255, 192, 203],
    purple:      [160, 0, 160],
    blue:        [0, 0, 255],
    deepBlue:    [0, 113, 176],
    lightBlue:   [50, 200, 255],
    vividBlue:   [0, 255, 255],
    green:       [0, 255, 0],
    yellow:      [255, 255, 0],
    vividOrange: [251, 176, 59],
    orange:      [247, 147, 30],
    beige:       [198, 156, 109],
    vividGreen:  [127, 200, 33],
    darkGreen:   [85, 107, 47],
    gray:        [128, 128, 128],
    black:       [20, 20, 20],
    white:       [255, 255, 255],
};

// 履歴を表すクラス
class History {
    constructor(canvas) {
        this.top = 0;
        this.current = 0;
        this.log = [canvas];
        this.canvas = canvas;
    }

    // 現在の状態を記録
    push() {
        // ログ用のキャンバスを用意
        let logCanvas = document.createElement("canvas");
        logCanvas.width = this.canvas.width;
        logCanvas.height = this.canvas.height;

        // 現在の状態をコピー
        let logContext = logCanvas.getContext("2d");
        logContext.drawImage(this.canvas, 0, 0);

        // 更新
        this.current++;
        this.top = this.current;
        this.log[this.current] = logCanvas;
    }

    // 元に戻す
    undo() {
        if (this.current <= 0) {
            return null;
        } else {
            this.current--;
            return this.log[this.current];
        }
    }

    // やり直し
    redo() {
        if (this.current >= this.top) {
            return null;
        } else {
            this.current++;
            return this.log[this.current];
        }
    }
}

// キャンバス
let imageCanvas;
let imageContext;
let canvas;
let context;
let history;

// 座標
let x, y;
let px, py;

// ペン
let mode = Mode.pen;
let color = Color.black;
let weight = 10;
let drawing = false;

// 初期化
function init() {
    // キャンバスを取得
    canvas = document.getElementById("canvas");
    context = canvas.getContext("2d");
    imageCanvas = document.getElementById("imageCanvas");
    imageContext = imageCanvas.getContext("2d");
    history = new History(canvas);

    // イベントリスナーを登録
    canvas.addEventListener("mousemove", onMove, false);
    canvas.addEventListener("mousedown", onClick, false);
    canvas.addEventListener("mouseup", drawEnd, false);
    canvas.addEventListener("mouseover", drawEnd, false);
}

// マウスアップ
function drawEnd() {
    if (drawing)
        history.push();

    px = null;
    py = null;
    drawing = false;
}

// クリック
function onClick(e) {
    drawing = true;
    e.preventDefault();
    const rect = e.target.getBoundingClientRect();

    x = e.clientX - rect.left;
    y = e.clientY - rect.top;
    drawLine(x, y);
}

// ドラッグ
function onMove(e) {
    // マウスが押されている場合にのみ処理を実行
    if (!drawing)
        return;

    e.preventDefault();
    const rect = e.target.getBoundingClientRect();

    x = e.clientX - rect.left;
    y = e.clientY - rect.top;
    drawLine(x, y);
}

// 線を引く
function drawLine(X, Y) {
    // キャンバスの描画モードを変更
    switch (mode) {
        case Mode.pen: // ペン
            context.globalCompositeOperation = "source-over";
            break;

        case Mode.eraser: // 消しゴム
            context.globalCompositeOperation = "destination-out";
            break;
    }

    context.lineCap = "round";
    context.strokeStyle = "rgb(" + color[0] + "," + color[1] + "," + color[2] + ")";
    context.lineWidth = weight;
    context.beginPath();

    if (px == null || py == null)
        context.moveTo(X, Y);
    else
        context.moveTo(px, py);

    context.lineTo(X, Y);
    context.stroke();
    context.closePath();

    px = X;
    py = Y;
}

// 元に戻す
function undo() {
    copyCanvas(history.undo());
}

// やり直し
function redo() {
    copyCanvas(history.redo());
}

// キャンバスをコピー
function copyCanvas(srcCanvas) {
    if (srcCanvas == null)
        return;

    if (mode == Mode.eraser)
        context.globalCompositeOperation = "source-over";

    context.clearRect(0, 0, canvas.width, canvas.height);
    context.drawImage(srcCanvas, 0, 0);

    if (mode == Mode.eraser)
        context.globalCompositeOperation = "destination-out";
}

// 投稿
function post() {
    let finalCanvas = document.createElement("canvas")
    finalCanvas.width = canvas.width;
    finalCanvas.height = canvas.height;

    let finalContext = finalCanvas.getContext("2d");
    finalContext.drawImage(document.getElementById("imageCanvas"), 0, 0);
    finalContext.drawImage(canvas, 0, 0);

    let image = finalCanvas.toDataURL("image/png");
    document.forms.new_draw.image.value = image;
    document.forms.new_draw.submit();
}
