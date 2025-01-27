--- STEAMODDED HEADER
--- MOD_NAME: DeckViewer
--- MOD_ID: deckviewer
--- MOD_AUTHOR: [Kvilt]
--- MOD_DESCRIPTION: Shows the upcoming cards in the deck, in the console.

----------------------------------------------
------------MOD CODE -------------------------

local MAX_CARDS_TO_SHOW = 20
local LOG_COOLDOWN = true  -- Prevent message spam
local last_log_time = 0

-- Fixed value mapping using numerical keys
local VALUE_MAP = {
    [1] = "Ace", [2] = "2", [3] = "3", [4] = "4", [5] = "5",
    [6] = "6", [7] = "7", [8] = "8", [9] = "9", [10] = "10",
    [11] = "Jack", [12] = "Queen", [13] = "King"
}

local SUIT_SYMBOLS = {
    Spades = "♠", Hearts = "♥",
    Diamonds = "♦", Clubs = "♣"
}

local function get_card_identity(card)
    -- Ensure card and its base properties are accessible
    if not card or not card.base then
        print("Debug: Card or card.base is missing.")
        return "Unknown card"
    end

    -- Use card.base.name as fallback if available
    local card_name = card.base.name or ""

    -- Replace suit names with symbols
    card_name = card_name:gsub(" of Spades", "♠")
                         :gsub(" of Hearts", "♥")
                         :gsub(" of Diamonds", "♦")
                         :gsub(" of Clubs", "♣")

    -- Replace face card names with abbreviations
    card_name = card_name:gsub("King", "K")
                         :gsub("Queen", "Q")
                         :gsub("Jack", "J")
                         :gsub("Ace", "A")

    return card_name
end

local function log_upcoming_cards()
    if not G or not G.deck or not G.deck.cards then return end

    -- Prevent spamming with cooldown check
    if LOG_COOLDOWN and (os.time() - last_log_time < 1) then return end
    last_log_time = os.time()

    local remaining = #G.deck.cards
    if remaining == 0 then return end

    local output = "Next cards: "
    for i = 1, math.min(MAX_CARDS_TO_SHOW, remaining) do
        local card = G.deck.cards[#G.deck.cards - i + 1]
        output = output .. (i > 1 and ", " or "") .. get_card_identity(card)
    end
    print("-------------------")
    print(output)
end

-- Preserve original UI functions
local original_start_round = G.FUNCS.start_round
local original_draw = G.FUNCS.draw_from_deck_to_hand

-- Modified round start with UI preservation
G.FUNCS.start_round = function(e)
    original_start_round(e)  -- Maintain original UI calls
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.5,
        func = function()
            if G.STATE == G.STATES.ROUND_EVAL then
                log_upcoming_cards()
            end
            return true
        end
    }))
end

-- Safe draw hook with UI preservation
G.FUNCS.draw_from_deck_to_hand = function(e)
    original_draw(e)  -- Maintain original UI calls
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.3,
        func = function()
            if G.STATE == G.STATES.DRAW_TO_HAND then
                log_upcoming_cards()
            end
            return true
        end
    }))
end

----------------------------------------------
------------MOD CODE END----------------------
