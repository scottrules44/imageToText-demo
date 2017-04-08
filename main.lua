local imageToText = require "plugin.imageToText"
local json = require "json"
local widget = require "widget"
timer.performWithDelay(1000, function (  )
    --utils needed for android
    local function doesFileExist( fname, path )

        local results = false

        -- Path for the file
        local filePath = system.pathForFile( fname, path )

        if ( filePath ) then
            local file, errorString = io.open( filePath, "r" )

            if not file then
                -- Error occurred; output the cause
                print( "File error: " .. errorString )
            else
                -- File exists!
                print( "File found: " .. fname )
                results = true
                -- Close the file handle
                file:close()
            end
        end

        return results
    end
    function copyFile( srcName, srcPath, dstName, dstPath, overwrite )

        local results = false

        local fileExists = doesFileExist( srcName, srcPath )
        if ( fileExists == false ) then
            return nil  -- nil = Source file not found
        end

        -- Check to see if destination file already exists
        if not ( overwrite ) then
            if ( fileLib.doesFileExist( dstName, dstPath ) ) then
                return 1  -- 1 = File already exists (don't overwrite)
            end
        end

        -- Copy the source file to the destination file
        local rFilePath = system.pathForFile( srcName, srcPath )
        local wFilePath = system.pathForFile( dstName, dstPath )

        local rfh = io.open( rFilePath, "rb" )
        local wfh, errorString = io.open( wFilePath, "wb" )

        if not ( wfh ) then
            -- Error occurred; output the cause
            print( "File error: " .. errorString )
            return false
        else
            -- Read the file and write to the destination directory
            local data = rfh:read( "*a" )
            if not ( data ) then
                print( "Read error!" )
                return false
            else
                if not ( wfh:write( data ) ) then
                    print( "Write error!" )
                    return false
                end
            end
        end

        results = 2  -- 2 = File copied successfully!
        -- Close file handles
        rfh:close()
        wfh:close()

        return results
    end
    --we need to move our image to documents (or temp) to work on android
    copyFile("test.png.txt", nil, "test.png", system.DocumentsDirectory, true)
    ---
    local bg = display.newRect( display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight )
    bg:setFillColor(1,0,0)
    local title = display.newText( "Image To Text", display.contentCenterX, 50, native.systemFont, 22 )


    --request premission for 6.0+
    native.showPopup( "requestAppPermission", {
       appPermission = "Storage", urgency = "Critical", listener= function ( e )

    end} )

    if system.getInfo( "environment" ) == "device" and system.getInfo( "platform" ) == "android" then
      imageToText.transferLanguage( system.pathForFile( "eng.traineddata" ))
      --print(json.encode(imageToText.listLanguages()))
      --imageToText.deleteLanguage("eng")
    end
    --predeclare text
    local myText = display.newText( "................", display.contentCenterX, display.contentCenterY+200,  native.systemFont, 18)
    --------
    imageToText.init(function (e)
      if e.response and e.response ~= "" then
        print( e.response )
        myText.text = e.response
      end
    end)
    local convert = widget.newButton( {label = "Convert To Text", onRelease = function  ()
        imageToText.convert(system.pathForFile( "test.png", system.DocumentsDirectory ), "eng")
    end} )

    convert.x, convert.y = display.contentCenterX, display.contentCenterY+100
    timer.performWithDelay( 100, function  ()
      local imageToConvert = display.newImageRect( "test.png", system.DocumentsDirectory , 100, 50 )
      imageToConvert.x, imageToConvert.y= display.contentCenterX, display.contentCenterY
    end )
end)