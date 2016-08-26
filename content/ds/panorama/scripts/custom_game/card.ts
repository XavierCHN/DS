enum CardType {
    CARD_TYPE_ATTRIBUTE = 0,
    CARD_TYPE_SPELL = 2,
    CARD_TYPE_MINION = 3,
    CARD_TYPE_EQUIPMENT = 4
}

// 卡牌基类
class Card{

    // 卡牌的ID
    card_id:number = -1;
    // 用以显示的panel
    panel: Panel;
    // 卡片类型
    cardType: CardType;
    // 是否即将删除
    shouldRemove: boolean = false;
    // 高亮状态
    highLightState :string = "";
    // 卡片数据
    cardData:any;

    constructor(parent: Panel, id: number, cardType: number, cardData: any){
        this.card_id = id;
        this.cardType = cardType;
        this.cardData = cardData;
        this.panel = $.CreatePanel("Panel", parent, "");

        switch (cardType){
            case CardType.CARD_TYPE_ATTRIBUTE:
                this.panel.AddClass("AttributeCard");
                break;
            case CardType.CARD_TYPE_MINION:
                this.panel.AddClass("MinionCard");
                break;
            case CardType.CARD_TYPE_SPELL:
                this.panel.AddClass("SpellCard");
                break;
            case CardType.CARD_TYPE_EQUIPMENT:
                this.panel.AddClass("EquipmentCard");
                break;
        }

        this.panel.BLoadLayoutSnippet("Card");
        this.UpdateCardMessage();
    }

    UpdateCardMessage(){
        let str = ('00000'+this.card_id);
        let dig_5_card_id = str.substring(str.length-5,str.length);
        
        // 设置卡片图片
        this.panel.FindChildTraverse("CardIllusion").SetImage(`file://{resources}/images/custom_game/cards/${dig_5_card_id}.png`)
        
        // 设置卡片名称和类别
        this.panel.FindChildTraverse("CardName").text = $.Localize(`#CardName_${dig_5_card_id}`);
        let prefix_type_str = "";
        let card_type_str = $.Localize(`#CardType_${this.cardType}`);
        let sub_type_str = "";
        let pt = this.cardData.prefix_type;
        let st = this.cardData.sub_type;
        for (let id in pt){
            prefix_type_str += $.Localize(`#PrefixType_${pt[id]}`)
        }
        for(let id in st){
            sub_type_str += $.Localize(`#SubType_${st[id]}`);
        }
        this.panel.FindChildTraverse("CardType").text = `${prefix_type_str}${card_type_str} ~ ${sub_type_str}`

        // 设置卡片描述
        let abilities = this.cardData.abilities;
        let ability_descriptions = "";
        if (abilities !== undefined){
            for(let aid in abilities){
                ability_descriptions += `${$.Localize(`Ability_${abilities[aid]}`)} `;
                ability_descriptions += " ";
            }
        }
        let card_description = $.Localize(`#CardDescription_${dig_5_card_id}`);
        if (card_description == `CardDescription_${dig_5_card_id}`) card_description = "";
       this.panel.FindChildTraverse("CardDescription").text = `${ability_descriptions}\n${card_description}`;

        let card_lore = $.Localize(`#CardLore_${dig_5_card_id}`);
        if (card_lore == "" || card_lore == `CardLore_${dig_5_card_id}`){
            $("#CardLore").AddClass("Empty");
        }else{
            $("#CardLore").RemoveClass("Empty");
            $("#CardLore").text = card_lore;
        }

        this.panel.FindChildTraverse("CardID").text = `${$.Localize("#CardID")}:${dig_5_card_id}`
        this.panel.FindChildTraverse("IllusionArtist").text = `${$.Localize("#CardArtist")}:${this.cardData.artist || $.Localize("#Unknown")}`
    }
}

// 手牌类
class HandCard extends Card{
    // 手牌的唯一ID，用以标识这张手牌
    uniqueId:string = "";

    constructor(parent:Panel, id: number, uniqueId: string, cardType: number, cardData:any){

        super(parent, id, cardType, cardData);
        this.uniqueId = uniqueId;
        this.panel.SetPanelEvent("onmouseover", this.ShowHandCardTooltip.bind(this));
        this.panel.SetPanelEvent("onmouseout",  this.HideHandCardTooltip.bind(this));
        this.panel.SetPanelEvent("onactivate",  this.OnClickCard.bind(this));
        this.panel.SetHasClass("HandCard", true);        
        $.Msg(`New card instance is created, cardid=${this.card_id}, uniqueId = ${this.uniqueId}`)
    }

    ShowHandCardTooltip(){
    }

    HideHandCardTooltip(){
    }

    OnClickCard(){
        GameEvents.SendCustomGameEventToServer(`ds_player_click_card`, {
            PlayerID:Players.GetLocalPlayer(),
            UniqueId:this.uniqueId,
        })
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

// 卡牌收藏中的牌
class CollectionCard extends Card{
    constructor(parent, id, cardType, cardData){
        super(parent, id, cardType, cardData)
    }
}

// 套牌中的牌（小牌）
class SmallDeckCard{
    cardId:number;
    cardCount:number;
    constructor(cardId, count){
        this.cardId = cardId;
        this.cardCount = count;
    }
}