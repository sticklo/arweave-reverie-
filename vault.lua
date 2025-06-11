-- -- Token Contract for Content Vault
-- -- This handles token minting, transfers, and ownership verification

-- -- Initialize state if not already defined
-- if not Balances then
--   Balances = {}
-- end

-- if not TokenInfo then
--   TokenInfo = {
--     name = "Content Access Token",
--     ticker = "CAT",
--     logo = "", -- Can be updated with Arweave TX ID of logo
--     supply = 0,
--     mintPrice = 1000000000, -- 1 AR in winston (10^9)
--     creator = ao.id -- Process ID is the creator by default
--   }
-- end

-- -- Content registry to store encrypted content references
-- if not ContentRegistry then
--   ContentRegistry = {}
-- end

-- -- Access keys for content (maps content IDs to encryption keys)
-- if not AccessKeys then
--   AccessKeys = {}
-- end

-- -- Utility function to reply to messages
-- local function Reply(msg, data, tags)
--   tags = tags or {}
--   if msg.reply then
--     msg.reply({ Data = data, Tags = tags })
--   else
--     ao.send({
--       Target = msg.From,
--       Data = data,
--       Tags = tags
--     })
--   end
-- end

-- -- Check if a user has tokens
-- local function hasTokens(address)
--   return (Balances[address] or 0) > 0
-- end

-- -- Update token info
-- Handlers.add(
--   "UpdateTokenInfo",
--   { Action = "UpdateTokenInfo" },
--   function(msg)
--     -- Only creator can update token info
--     if msg.From ~= TokenInfo.creator then
--       return Reply(msg, "Only the creator can update token info")
--     end
    
--     -- Update token info fields
--     if msg.Tags.Name then TokenInfo.name = msg.Tags.Name end
--     if msg.Tags.Ticker then TokenInfo.ticker = msg.Tags.Ticker end
--     if msg.Tags.Logo then TokenInfo.logo = msg.Tags.Logo end
--     if msg.Tags.MintPrice then TokenInfo.mintPrice = tonumber(msg.Tags.MintPrice) end
    
--     Reply(msg, "Token info updated successfully")
--   end
-- )

-- -- Mint tokens
-- Handlers.add(
--   "Mint",
--   { Action = "Mint" },
--   function(msg)
--     local quantity = tonumber(msg.Tags.Quantity or "1")
    
--     -- Check if payment is required and validate
--     if TokenInfo.mintPrice > 0 then
--       -- In a real implementation, you would verify AR payment here
--       -- For MVP, we'll assume payment is handled separately or free
--     end
    
--     -- Mint tokens to the sender
--     Balances[msg.From] = (Balances[msg.From] or 0) + quantity
--     TokenInfo.supply = TokenInfo.supply + quantity
    
--     Reply(msg, "Successfully minted " .. quantity .. " " .. TokenInfo.ticker .. " tokens", 
--       { 
--         ["Token-Name"] = TokenInfo.name,
--         ["Token-Balance"] = tostring(Balances[msg.From])
--       }
--     )
--   end
-- )

-- -- Transfer tokens
-- Handlers.add(
--   "Transfer",
--   { Action = "Transfer" },
--   function(msg)
--     local recipient = msg.Tags.Recipient
--     local quantity = tonumber(msg.Tags.Quantity or "1")
    
--     if not recipient then
--       return Reply(msg, "Recipient is required")
--     end
    
--     if not Balances[msg.From] or Balances[msg.From] < quantity then
--       return Reply(msg, "Insufficient balance")
--     end
    
--     -- Transfer tokens
--     Balances[msg.From] = Balances[msg.From] - quantity
--     Balances[recipient] = (Balances[recipient] or 0) + quantity
    
--     Reply(msg, "Successfully transferred " .. quantity .. " " .. TokenInfo.ticker .. " tokens to " .. recipient)
    
--     -- Notify recipient
--     ao.send({
--       Target = recipient,
--       Data = "You received " .. quantity .. " " .. TokenInfo.ticker .. " tokens from " .. msg.From,
--       Tags = {
--         ["Action"] = "Token-Received",
--         ["Sender"] = msg.From,
--         ["Quantity"] = tostring(quantity),
--         ["Token-Name"] = TokenInfo.name
--       }
--     })
--   end
-- )

-- -- Get token balance
-- Handlers.add(
--   "Balance",
--   { Action = "Balance" },
--   function(msg)
--     local target = msg.Tags.Target or msg.From
--     local balance = Balances[target] or 0
    
--     Reply(msg, tostring(balance), {
--       ["Balance"] = tostring(balance),
--       ["Target"] = target,
--       ["Token-Name"] = TokenInfo.name,
--       ["Token-Ticker"] = TokenInfo.ticker
--     })
--   end
-- )

-- -- Get token info
-- Handlers.add(
--   "TokenInfo",
--   { Action = "TokenInfo" },
--   function(msg)
--     Reply(msg, {
--       name = TokenInfo.name,
--       ticker = TokenInfo.ticker,
--       logo = TokenInfo.logo,
--       supply = TokenInfo.supply,
--       mintPrice = TokenInfo.mintPrice,
--       creator = TokenInfo.creator
--     })
--   end
-- )

-- -- Register content (creator only)
-- Handlers.add(
--   "RegisterContent",
--   { Action = "RegisterContent" },
--   function(msg)
--     -- Only creator can register content
--     if msg.From ~= TokenInfo.creator then
--       return Reply(msg, "Only the creator can register content")
--     end
    
--     local contentId = msg.Tags.ContentId
--     local encryptionKey = msg.Tags.EncryptionKey
--     local contentType = msg.Tags.ContentType or "text/plain"
--     local title = msg.Tags.Title or "Untitled"
--     local description = msg.Tags.Description or ""
    
--     if not contentId or not encryptionKey then
--       return Reply(msg, "ContentId and EncryptionKey are required")
--     end
    
--     -- Register the content
--     ContentRegistry[contentId] = {
--       id = contentId,
--       type = contentType,
--       title = title,
--       description = description,
--       creator = msg.From,
--       timestamp = os.time()
--     }
    
--     -- Store the encryption key
--     AccessKeys[contentId] = encryptionKey
    
--     Reply(msg, "Content registered successfully")
--   end
-- )

-- -- List available content (public)
-- Handlers.add(
--   "ListContent",
--   { Action = "ListContent" },
--   function(msg)
--     local contentList = {}
    
--     for id, content in pairs(ContentRegistry) do
--       table.insert(contentList, {
--         id = id,
--         title = content.title,
--         description = content.description,
--         type = content.type,
--         timestamp = content.timestamp
--       })
--     end
    
--     Reply(msg, contentList)
--   end
-- )

-- -- Request access to content
-- Handlers.add(
--   "RequestAccess",
--   { Action = "RequestAccess" },
--   function(msg)
--     local contentId = msg.Tags.ContentId
    
--     if not contentId then
--       return Reply(msg, "ContentId is required")
--     end
    
--     if not ContentRegistry[contentId] then
--       return Reply(msg, "Content not found")
--     end
    
--     -- Check if user has tokens
--     if not hasTokens(msg.From) then
--       return Reply(msg, "Access denied: You need to own " .. TokenInfo.ticker .. " tokens to access this content")
--     end
    
--     -- Grant access by providing the encryption key
--     Reply(msg, "Access granted", {
--       ["Content-Id"] = contentId,
--       ["Encryption-Key"] = AccessKeys[contentId],
--       ["Content-Type"] = ContentRegistry[contentId].type
--     })
--   end
-- )

-- -- Verify token ownership (for external services)
-- Handlers.add(
--   "VerifyOwnership",
--   { Action = "VerifyOwnership" },
--   function(msg)
--     local address = msg.Tags.Address or msg.From
    
--     Reply(msg, hasTokens(address), {
--       ["Has-Tokens"] = tostring(hasTokens(address)),
--       ["Balance"] = tostring(Balances[address] or 0)
--     })
--   end
-- )

-- vault.lua
-- Token‐Gated Content Vault (AO / Arweave Lua)

-- Initialize state if not already defined
if not Balances then
  Balances = {}
end

if not TokenInfo then
  TokenInfo = {
    name = "Content Access Token",
    ticker = "CAT",
    logo = "", -- Can be updated with Arweave TX ID of logo
    supply = 0,
    mintPrice = 1000000000,  -- 1 AR in Winston (10^9)
    creator   = ao.id         -- process ID is the “creator” by default
  }
end

-- Registry of encrypted content references
if not ContentRegistry then
  ContentRegistry = {}
end

-- Map content IDs → encryption keys
if not AccessKeys then
  AccessKeys = {}
end

-- The AOS‐Token process ID (must match what your index.html uses)
AOS_TOKEN_PROCESS_ID = "kUet9IGoa4zu_LQ1lcGXLX9XXKUcWzD6fPk8TRjoHXQ"
-- ←– Make sure this is the *actual* token‐contract ID

--[[-------------------------------------------------------------------------------------------------------------------------
   Utility: Reply
   • Always use msg.owner (caller’s address) as the Target.
   • Always use msg.id      (incoming message ID) as the “Reference” tag.
   • This ensures that the frontend’s result({ process: VAULT_ID, message: <txID> }) will actually see your reply. 
---------------------------------------------------------------------------------------------------------------------------]]
local function Reply(msg, data, tags)
  tags = tags or {}
  local replyTags = {
    ["Action"]    = tags["Action"]    or "Response",
    ["Status"]    = tags["Status"]    or "Info",
    ["Reference"] = msg.id,  -- must be the exact incoming TX ID
  }

  -- copy any custom tags (but avoid overwriting the three core tags above)
  for k, v in pairs(tags) do
    if k ~= "Action" and k ~= "Status" and k ~= "Reference" then
      replyTags[k] = v
    end
  end

  -- Build replyData: if it's a table → JSON‐encode; else as string
  local replyData = nil
  if type(data) == "string" or type(data) == "number" then
    replyData = tostring(data)
  elseif type(data) == "table" then
    local ok, json_str = pcall(JSON.stringify, data)
    if ok then
      replyData = json_str
      replyTags["Content-Type"] = "application/json"
    else
      -- fallback if JSON.stringify fails
      print("WARNING: Failed to JSON.stringify reply data:", json_str)
      replyData = "Failed to serialize response table."
    end
  end

  print("DEBUG (Vault): Sending reply to", msg.owner)
  print("DEBUG (Vault): ReplyTags:", JSON.stringify(replyTags))
  print("DEBUG (Vault): ReplyData:", replyData or "")

  ao.send({
    Target = msg.owner,
    Tags   = replyTags,
    Data   = replyData,
  })
end

-- Check if a given address holds at least one vault‐minted token
local function hasTokens(address)
  return (Balances[address] or 0) > 0
end

--–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- UPDATE TOKEN INFO (only vault creator can call this)
--–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
Handlers.add(
  "UpdateTokenInfo",
  { Action = "UpdateTokenInfo" },
  function(msg)
    print("DEBUG (Vault): Received UpdateTokenInfo from", msg.owner)
    if msg.owner ~= TokenInfo.creator then
      return Reply(msg, "Only the creator can update token info", { Status = "Error" })
    end

    if msg.Tags.Name      then TokenInfo.name      = msg.Tags.Name      end
    if msg.Tags.Ticker    then TokenInfo.ticker    = msg.Tags.Ticker    end
    if msg.Tags.Logo      then TokenInfo.logo      = msg.Tags.Logo      end
    if msg.Tags.MintPrice then TokenInfo.mintPrice = tonumber(msg.Tags.MintPrice) end

    Reply(msg, "Token info updated successfully", { Status = "Success" })
  end
)

--–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- MINT HANDLER (relays the mint request to the actual token‐contract, then replies)
--–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
Handlers.add(
  "Mint",
  { Action = "Mint" },
  function(msg)
    print("DEBUG (Vault): Received Mint request from", msg.owner, "msg.id:", msg.id)
    local wallet_address      = msg.owner
    local quantity_requested  = tonumber(msg.Tags.Quantity or "1")
    local ar_paid             = 0

    if msg.data and msg.data ~= "" then
      ar_paid = tonumber(msg.data) or 0
    end

    -- Check payment
    if TokenInfo.mintPrice > 0 then
      print("DEBUG (Vault): Checking AR payment. Paid:", ar_paid, "Required:", TokenInfo.mintPrice)
      if ar_paid < TokenInfo.mintPrice then
        return Reply(msg,
          "Insufficient AR payment. Required: " .. TokenInfo.mintPrice .. " Winston (AR). Received: " .. ar_paid .. " Winston (AR).",
          {
            Action = "Mint-Response",
            Status = "Error",
            Error  = "Insufficient AR payment."
          }
        )
      end
    end

    -- Relay to the actual token contract
    print("DEBUG (Vault): Forwarding Mint to Token Process:", AOS_TOKEN_PROCESS_ID)
    local ok, err = pcall(function()
      ao.send({
        Target = AOS_TOKEN_PROCESS_ID,
        Tags = {
          ["Action"]    = "Mint",
          ["Quantity"]  = tostring(quantity_requested),
          ["Recipient"] = wallet_address
        }
        -- (We do *not* send Data here, since the token contract usually only cares about tags)
      })
    end)

    if ok then
      print("DEBUG (Vault): Successfully relayed to token process. Now replying to front‐end.")
      Reply(msg,
        "Mint request successfully forwarded. The token contract will mint shortly.",
        {
          Action            = "Mint-Response",
          Status            = "Success",
          ["Token-Name"]    = TokenInfo.name,
          ["Quantity-Requested"] = tostring(quantity_requested)
        }
      )
    else
      print("DEBUG (Vault): Failed to relay mint to token process. Error:", err)
      Reply(msg,
        "Failed to relay mint request to token process: " .. tostring(err),
        {
          Action = "Mint-Response",
          Status = "Error",
          Error  = "Failed to send mint request to token process.",
          ["Details"] = tostring(err)
        }
      )
    end
  end
)

--–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- TRANSFER TOKENS (updates local Balances map, purely illustrative—your token‐contract actually duplicates this)
--–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
Handlers.add(
  "Transfer",
  { Action = "Transfer" },
  function(msg)
    print("DEBUG (Vault): Received Transfer from", msg.owner)
    local recipient = msg.Tags.Recipient
    local quantity  = tonumber(msg.Tags.Quantity or "1")

    if not recipient then
      return Reply(msg, "Recipient is required", { Status = "Error" })
    end

    if not Balances[msg.owner] or Balances[msg.owner] < quantity then
      return Reply(msg, "Insufficient balance", { Status = "Error" })
    end

    Balances[msg.owner]       = Balances[msg.owner] - quantity
    Balances[recipient]       = (Balances[recipient] or 0) + quantity

    Reply(msg,
      "Successfully transferred " .. quantity .. " " .. TokenInfo.ticker .. " tokens to " .. recipient,
      { Status = "Success" }
    )

    -- Notify recipient
    ao.send({
      Target = recipient,
      Data   = "You received " .. quantity .. " " .. TokenInfo.ticker .. " tokens from " .. msg.owner,
      Tags   = {
        ["Action"]     = "Token-Received",
        ["Sender"]     = msg.owner,
        ["Quantity"]   = tostring(quantity),
        ["Token-Name"] = TokenInfo.name
      }
    })
  end
)

--–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- BALANCE QUERY (returns how many tokens this address holds, as tracked in this `Balances` table)
--–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
Handlers.add(
  "Balance",
  { Action = "Balance" },
  function(msg)
    print("DEBUG (Vault): Received Balance query from", msg.owner)
    local target  = msg.Tags.Target or msg.owner
    local balance = Balances[target] or 0

    Reply(msg, tostring(balance), {
      Status       = "Success",
      ["Balance"]  = tostring(balance),
      ["Target"]   = target,
      ["Token-Name"]= TokenInfo.name,
      ["Token-Ticker"] = TokenInfo.ticker
    })
  end
)

--–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- TOKEN INFO QUERY (public: name, ticker, logo, supply, mintPrice, creator)
--–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
Handlers.add(
  "TokenInfo",
  { Action = "TokenInfo" },
  function(msg)
    print("DEBUG (Vault): Received TokenInfo query from", msg.owner)
    Reply(msg, {
      name       = TokenInfo.name,
      ticker     = TokenInfo.ticker,
      logo       = TokenInfo.logo,
      supply     = TokenInfo.supply,
      mintPrice  = TokenInfo.mintPrice,
      creator    = TokenInfo.creator
    }, { Status = "Success" })
  end
)

--–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- REGISTER (ENCRYPTED) CONTENT (only vault creator can do this)
--–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
Handlers.add(
  "RegisterContent",
  { Action = "RegisterContent" },
  function(msg)
    print("DEBUG (Vault): Received RegisterContent from", msg.owner)
    if msg.owner ~= TokenInfo.creator then
      return Reply(msg, "Only the creator can register content", { Status = "Error" })
    end

    local contentId     = msg.Tags.ContentId
    local encryptionKey = msg.Tags.EncryptionKey
    local contentType   = msg.Tags.ContentType or "text/plain"
    local title         = msg.Tags.Title or "Untitled"
    local description   = msg.Tags.Description or ""

    if not contentId or not encryptionKey then
      return Reply(msg, "ContentId and EncryptionKey are required", { Status = "Error" })
    end

    ContentRegistry[contentId] = {
      id          = contentId,
      type        = contentType,
      title       = title,
      description = description,
      creator     = msg.owner,
      timestamp   = os.time()
    }
    AccessKeys[contentId] = encryptionKey

    Reply(msg, "Content registered successfully", { Status = "Success" })
  end
)

--–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- LIST ALL REGISTERED CONTENT (public; doesn’t check tokens)
--–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
Handlers.add(
  "ListContent",
  { Action = "ListContent" },
  function(msg)
    print("DEBUG (Vault): Received ListContent from", msg.owner)
    local contentList = {}
    for id, content in pairs(ContentRegistry) do
      table.insert(contentList, {
        id          = id,
        title       = content.title,
        description = content.description,
        type        = content.type,
        timestamp   = content.timestamp
      })
    end
    Reply(msg, contentList, { Status = "Success" })
  end
)

--–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- REQUEST ACCESS TO A PIECE OF CONTENT (only if caller has ≥1 token in vault’s Balances map)
--–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
Handlers.add(
  "RequestAccess",
  { Action = "RequestAccess" },
  function(msg)
    print("DEBUG (Vault): Received RequestAccess from", msg.owner)
    local contentId = msg.Tags.ContentId
    if not contentId then
      return Reply(msg, "ContentId is required", { Status = "Error" })
    end
    if not ContentRegistry[contentId] then
      return Reply(msg, "Content not found", { Status = "Error" })
    end
    if not hasTokens(msg.owner) then
      return Reply(msg,
        "Access denied: You need to own " .. TokenInfo.ticker .. " tokens to access this content",
        { Status = "Error" }
      )
    end

    Reply(msg, "Access granted", {
      Status        = "Success",
      ["Content-Id"]= contentId,
      ["Encryption-Key"] = AccessKeys[contentId],
      ["Content-Type"]   = ContentRegistry[contentId].type
    })
  end
)

--–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- VERIFY TOKEN OWNERSHIP (for external services; returns boolean hasTokens(address))
--–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
Handlers.add(
  "VerifyOwnership",
  { Action = "VerifyOwnership" },
  function(msg)
    print("DEBUG (Vault): Received VerifyOwnership from", msg.owner)
    local address = msg.Tags.Address or msg.owner

    Reply(msg, hasTokens(address), {
      Status     = "Success",
      ["Has-Tokens"] = tostring(hasTokens(address)),
      ["Balance"]    = tostring(Balances[address] or 0)
    })
  end
)
