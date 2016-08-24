// 手牌类
var CardType;
(function (CardType) {
    CardType[CardType["ATTRIBUTE"] = 0] = "ATTRIBUTE";
    CardType[CardType["SPELL"] = 1] = "SPELL";
    CardType[CardType["MINION"] = 2] = "MINION";
    CardType[CardType["EQUIPMENT"] = 3] = "EQUIPMENT";
})(CardType || (CardType = {}));
var BehaviorType;
(function (BehaviorType) {
    BehaviorType[BehaviorType["NO_TARGET"] = 0] = "NO_TARGET";
    BehaviorType[BehaviorType["SINGLE_TARGET"] = 1] = "SINGLE_TARGET";
    BehaviorType[BehaviorType["POINT"] = 2] = "POINT";
    BehaviorType[BehaviorType["MULTIPLE_TARGET"] = 3] = "MULTIPLE_TARGET";
})(BehaviorType || (BehaviorType = {}));
var Hand = (function () {
    // highLightStates = []; // todo 卡牌高亮
    function Hand(parent, cardID, idx) {
        this.panel = $.CreatePanel("Panel", parent, "");
        this.panel.BLoadLayoutSnippet("HandCard");
        this.panel.style.visibility = "collapse";
        this.panel.SetPanelEvent("onmouseover", this.showTooltip.bind(this));
        this.panel.SetPanelEvent("onmouseover", this.hideTooltip.bind(this));
        this.panel.SetPanelEvent("onmouseover", this.onLeftClick.bind(this));
        // this.panel.SetPanelEvent("onmouseover", this.onRightClick.bind(this));
        this.id = cardID;
        this.idx = idx;
        var image = this.panel.FindChildTraverse("picture");
        image.SetImage("file://{resources}/images/custom_game/cards/" + this.id + ".png");
    }
    Hand.prototype.showTooltip = function () {
        // todo
    };
    Hand.prototype.hideTooltip = function () {
        // todo
    };
    // 发送指令到服务器，需要服务器验证是否能够使用之后再返回客户端使用proxy来释放马甲技能
    Hand.prototype.onLeftClick = function () {
        GameEvents.SendCustomGameEventToServer("ds_player_click_card", {
            CardIndex: this.idx,
        });
    };
    return Hand;
}());
