// // 属性卡
// class AttributeCard extends HandCard{
//     constructor(parent: Panel, id:number, uniqueId: string){
//         super(parent, id, uniqueId);
//         this.panel.BLoadLayoutSnippet("AttributeCard");
//     }
// }

// // 生物卡
// class MinionCard extends HandCard{
//     constructor(parent: Panel, id:number, uniqueId: string){
//         super(parent, id, uniqueId);
//         this.panel.BLoadLayoutSnippet("MinionCard");
//     }
// }

// // 法术卡
// class SpellCard extends HandCard{
//     constructor(parent: Panel, id:number, uniqueId: string){
//         super(parent, id, uniqueId);
//         this.panel.BLoadLayoutSnippet("SpellCard");
//     }
// }

// // 装备卡
// class EquipmentCard extends HandCard{
//     constructor(parent:Panel, id:number, uniqueId: string){
//         super(parent, id, uniqueId);
//         this.panel.BLoadLayoutSnippet("EquipmentCard");
//     }
// }

enum CardType {
    CARD_TYPE_ATTRIBUTE = 0,
    CARD_TYPE_SPELL = 2,
    CARD_TYPE_MINION = 3,
    CARD_TYPE_EQUIPMENT = 4
}

// 卡牌基类
class HandCard
{
    // 所显示的卡牌的ID
    card_id:number = -1;
    // 卡牌的唯一ID，在卡牌实例化的时候生成
    uniqueId:string = "";
    // 用以显示的panel
    panel: Panel;
    // 是否即将删除
    shouldRemove: boolean = false;
    // 高亮状态
    highLightState :string = "";

    constructor(parent:Panel, id: number, uniqueId: string, cardType: number){

        this.card_id = id;
        this.uniqueId = uniqueId;

        this.panel = $.CreatePanel("Panel", parent, "");
        
        this.panel.SetPanelEvent("onmouseover", this.ShowHandCardTooltip.bind(this));
        this.panel.SetPanelEvent("onmouseout",  this.HideHandCardTooltip.bind(this));
        this.panel.SetPanelEvent("onactivate",  this.OnClickCard.bind(this));

        switch (cardType){
            case CardType.CARD_TYPE_ATTRIBUTE:
                this.panel.BLoadLayoutSnippet("AttributeCard");
                break;
            case CardType.CARD_TYPE_MINION:
                this.panel.BLoadLayoutSnippet("MinionCard");
                break;
            case CardType.CARD_TYPE_SPELL:
                this.panel.BLoadLayoutSnippet("SpellCard");
                break;
            case CardType.CARD_TYPE_EQUIPMENT:
                this.panel.BLoadLayoutSnippet("EquipmentCard");
                break;
            default:
                this.panel.BLoadLayoutSnippet("HandCard");
        }

        $.Msg(`New card instance is created, cardid=${this.card_id}, uniqueId = ${this.uniqueId}`)
    }

    ShowHandCardTooltip(){
    }

    HideHandCardTooltip(){
    }

    OnClickCard(){
    }

    Remove(){
        this.panel.DeleteAsync(0);
    }

    UpdateHighlightState(newState:string):void{
        if(newState !== ""){
            this.panel.SetHasClass(newState, true)
        }else{
            this.panel.SetHasClass(this.highLightState, false);
        }
        this.highLightState = newState;
    }
}

