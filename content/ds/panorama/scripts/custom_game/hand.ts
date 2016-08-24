// 手牌类
enum CardType {
    ATTRIBUTE = 0,
    SPELL = 1,
    MINION = 2,
    EQUIPMENT = 3,
}

enum BehaviorType {
    NO_TARGET = 0,
    SINGLE_TARGET = 1,
    POINT = 2,
    MULTIPLE_TARGET = 3,
}

class Hand {
    panel: Panel;
    id:number;
    idx:number; // 手牌的顺序，1-7之类
    // highLightStates = []; // todo 卡牌高亮

	constructor(parent: Panel, cardID:number, idx:number) {
        this.panel = $.CreatePanel("Panel", parent, "");
        this.panel.BLoadLayoutSnippet("HandCard");

        this.panel.style.visibility = "collapse"

        this.panel.SetPanelEvent("onmouseover", this.showTooltip.bind(this));
        this.panel.SetPanelEvent("onmouseover", this.hideTooltip.bind(this));
        this.panel.SetPanelEvent("onmouseover", this.onLeftClick.bind(this));
        // this.panel.SetPanelEvent("onmouseover", this.onRightClick.bind(this));

        this.id = cardID;
        this.idx = idx;

        let image = <Image>this.panel.FindChildTraverse("picture");
        image.SetImage("file://{resources}/images/custom_game/cards/" + this.id + ".png");
	}

    showTooltip():void{
        // todo
    }

    hideTooltip():void{
        // todo
    }

    // 发送指令到服务器，需要服务器验证是否能够使用之后再返回客户端使用proxy来释放马甲技能
    onLeftClick():void{
        GameEvents.SendCustomGameEventToServer("ds_player_click_card", {
            CardIndex:this.idx,
        })
    }
}