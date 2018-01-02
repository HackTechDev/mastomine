minetest.register_chatcommand("toot", {

    -- Mastodon Toot
    params = "<message>",
    description = "Toot manager",
    func = function(user, args)

        -- Mastodon library
        local lfs = require("lfs")
        local mastodon = require("mastodon")

        -- change this to the apprpriate instance, login and username
        local instance_url = "<MASTODON URL>"
        local user_name = "<USER EMAIL>"
        local user_password = "<USER PASSWORD>"

        if lfs.attributes("secrets.lua") then
           dofile("secrets.lua")
           instance_url, user_name, user_password = get_secrets()
        end

        if not lfs.attributes("clientcred.txt") then
           print("No client credentials locally stored yet.")
           print("Will try to register app in server...")
           local id, err = mastodon.create_app {
              client_name = "Lua Test",
              scopes= { "read", "write" },
              to_file = "clientcred.txt",
              api_base_url = instance_url
           }
           if id then
              print("Successfully registered app - got ID " .. id)
           else
              print("Failed registering app in server :( - error: " .. err)
              os.exit(1)
           end
        end

        local mclient = mastodon.new {
           client_id = "clientcred.txt",
           api_base_url = instance_url
        }

        print("Logging in...")

        local access, err = mclient:log_in {
           username = user_name,
           password = user_password,
           scopes = { "read", "write" },
           to_file = "usercred.txt"
        }

        if not access then
           print("Login failed :( - error: " .. err)
           os.exit(1)
        end

        print("Logged in! :)")


        local access, err = mclient:log_in {
           username = user_name,
           password = user_password,
           scopes = { "read", "write" },
           to_file = "usercred.txt"
        }

        if not access then
           print("Login failed :( - error: " .. err)
           os.exit(1)
        end
        
        --
        
        if args == "" then
            return false, "Parameters required."
        end

        local actionName, param1, param2 = args:match("^(%S+)%s(%S+)%s(.*)$")

        if not param1 then
            return false, "Parameter 1 required"
        end

        if not param2 then
            return false, "Parameter 2 required"
        end
        
        local player = minetest.get_player_by_name(user)
        if not player then
            return false, "Player not found"
        end

        local fmt = "Toot: '%s' at: (%.2f,%.2f,%.2f)"

        local pos = player:getpos()

        -- Get world path:
        local path = minetest.get_worldpath()
        -- Get world name:
        local worldName = path:match( "([^/]+)$" )
        
        -- /toot send param
        if actionName == "send" then

            if param1 == "worldname" then 

                local toot = "[Minetest][World:" .. worldName .. "]"
            
                minetest.chat_send_player(user, "  toot: " .. toot)
                local result = mclient:toot(toot)

            elseif param1 == "playername" then 
                local toot = "[Minetest][Player:" .. user.. "] "
            
                minetest.chat_send_player(user, "  toot: " .. toot)
                local result = mclient:toot(toot)

            elseif param1 == "playerpos" then 
                local toot = "[Minetest][Pos:(" .. pos.x .. "," .. pos.y .. "," ..  pos.z .. ")]"
            
                minetest.chat_send_player(user, "  toot: " .. toot)
                local result = mclient:toot(toot)

            elseif param1 == "playerinfo" then 
                local toot = "[Minetest][World:" .. worldName .. "][Player:" .. user.. "][Pos:(" .. pos.x .. "," .. pos.y .. "," ..  pos.z .. ")]"
            
                minetest.chat_send_player(user, "  toot: " .. toot)
                local result = mclient:toot(toot)

            elseif param1 == "message" then 

                local toot = "[Minetest][Player:" .. user.. "] " .. param2
            
                minetest.chat_send_player(user, "  toot: " .. toot)
                local result = mclient:toot(toot)


            else 
                 return false, "No parameter"
            end

        else
            return false, "No action"
        end

        return true, fmt:format(args, pos.x, pos.y, pos.z)
    end
})



