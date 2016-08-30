enum CardType {
    CARD_TYPE_ATTRIBUTE = 0,
    CARD_TYPE_SPELL = 1,
    CARD_TYPE_MINION = 2,
    CARD_TYPE_EQUIPMENT = 3
}

enum CardAttribute {
    ATTRIBUTE_NONE = 0,
    ATTRIBUTE_STRENGTH = 1,
    ATTRIBUTE_AGILITY = 2,
    ATTRIBUTE_INTELLECT = 3
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
    
    // 卡片数据
    cardData:any;

    constructor(parent: Panel, id: number, cardType: number, cardData: any){
        this.card_id = id;
        this.cardType = cardType;
        this.cardData = cardData;
        this.panel = $.CreatePanel("Panel", parent, "");
        switch(this.cardData.main_attr){
            case CardAttribute.ATTRIBUTE_STRENGTH:
                this.panel.AddClass("MainAttributeStrength");
                break;
            case CardAttribute.ATTRIBUTE_AGILITY:
                this.panel.AddClass("MainAttributeAgility");
                break;
            case CardAttribute.ATTRIBUTE_INTELLECT:
                this.panel.AddClass("MainAttributeIntellect");
                break;
            case CardAttribute.ATTRIBUTE_NONE:
                this.panel.AddClass("MainAttributeNone");
                break;
        }

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
        
        // 设置费用
        let cost_panel = this.panel.FindChildTraverse("CardCost");
        let mana_label = this.panel.FindChildTraverse("CardCost_Mana");
        let attr_panel = this.panel.FindChildTraverse("CardCost_Attributes");
        let str_cost = this.cardData.cost.str;
        let agi_cost = this.cardData.cost.agi;
        let int_cost = this.cardData.cost.int;
        let mana_cost = this.cardData.cost.mana;
        if (
            ( str_cost == undefined || str_cost <= 0) &&
            ( agi_cost == undefined || agi_cost <= 0) &&
            ( int_cost == undefined || int_cost <= 0) &&
            ( mana_cost == undefined || mana_cost <= 0)
        ){
            cost_panel.AddClass("NoCost");
        }else{
            cost_panel.RemoveClass("NoCost");
            attr_panel.RemoveAndDeleteChildren();
            if(str_cost !== undefined && str_cost > 0){
                for( let i:number = 0;i < str_cost; i++){
                    let s = $.CreatePanel("Image", attr_panel, "");
                    s.SetImage("file://{resources}/images/custom_game/card/card_cost_str.png");
                }
            }
            if(agi_cost !== undefined && agi_cost > 0){
                for( let i:number = 0;i < agi_cost; i++){
                    let s = $.CreatePanel("Image", attr_panel, "");
                    s.SetImage("file://{resources}/images/custom_game/card/card_cost_agi.png");
                }
            }
            if(int_cost !== undefined && int_cost > 0){
                for( let i:number = 0;i < int_cost; i++){
                    let s = $.CreatePanel("Image", attr_panel, "");
                    s.SetImage("file://{resources}/images/custom_game/card/card_cost_int.png");
                }
            }

            mana_cost = mana_cost || 0;
            mana_label.text = mana_cost;
        }
        

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
        this.panel.FindChildTraverse("CardType").text = `${prefix_type_str}${card_type_str} ${sub_type_str==""?"":"~"} ${sub_type_str}`

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
       this.panel.FindChildTraverse("CardDescription").text = `${ability_descriptions}${ability_descriptions == ""?"":"\n"}${card_description}`;
        let card_lore = $.Localize(`#CardLore_${dig_5_card_id}`);
        if (card_lore == "" || card_lore == `CardLore_${dig_5_card_id}`){
            $.Msg("empty");
            this.panel.FindChildTraverse("CardLore").AddClass("Empty");
            this.panel.FindChildTraverse("CardLore").text = card_lore;
        }else{
            this.panel.FindChildTraverse("CardLore").RemoveClass("Empty");
            this.panel.FindChildTraverse("CardLore").text = card_lore;
        }

        this.panel.FindChildTraverse("CardID").text = `${$.Localize("#CardID")}:${dig_5_card_id}`
        this.panel.FindChildTraverse("IllusionArtist").text = `${$.Localize("#CardArtist")}:${this.cardData.artist || $.Localize("#Unknown")}`

        // 设置生物的攻击力和防御力
        if(this.cardType == CardType.CARD_TYPE_MINION){
            let ad_panel = this.panel.FindChildTraverse("AttackDefLabel");
            ad_panel.text = `${this.cardData.atk}/${this.cardData.hp}`;
        }
    }
}

// 手牌类
class HandCard extends Card{
    // 手牌的唯一ID，用以标识这张手牌
    uniqueId:string = "";

    // 用以记录当前手牌数量
    handCount: number = 1;

    // 高亮状态
    highLightState :string = "";

    constructor(parent:Panel, id: number, uniqueId: string, cardType: number, cardData:any){

        super(parent, id, cardType, cardData);
        this.uniqueId = uniqueId;
        this.panel.SetPanelEvent("onmouseover", this.ShowHandCardTooltip.bind(this));
        this.panel.SetPanelEvent("onmouseout",  this.HideHandCardTooltip.bind(this));
        this.panel.SetPanelEvent("onactivate",  this.OnClickCard.bind(this));
        this.panel.SetHasClass("HandCard", true);
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
        this.panel.SetHasClass(this.highLightState, false);
        this.panel.SetHasClass(newState, true);
        this.highLightState = newState;
    }

    SetHandCount(count: number){
        this.panel.SetHasClass(`CardCount_${this.handCount}`, false);
        this.handCount = count;
        this.panel.SetHasClass(`CardCount_${this.handCount}`, true);
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