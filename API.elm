port module API exposing (..)

import Json.Decode
import Serverless
import Serverless.Conn exposing (..)
import Serverless.Conn.Response exposing (..)


{-| A Serverless.Program is parameterized by your 3 custom types

* Config is a server load-time record of deployment specific values
* Model is for whatever you need during the processing of a request
* Msg is your app message type
-}
main : Serverless.Program Config Model Msg
main =
    Serverless.httpApi
        { configDecoder = configDecoder
        , requestPort = requestPort
        , responsePort = responsePort
        , endpoint = Endpoint
        , initialModel = Model 0
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


{-| Serverless.Conn.Conn is short for connection.

It is parameterized by the Config and Model record types.
For convenience we create an alias.
-}
type alias Conn =
    Serverless.Conn.Conn Config Model


{-| Can be anything you want, you just need to provide a decoder
-}
type alias Config =
    { something : String
    }


{-| Can be anything you want.
This will get set to initialModel (see above) for each incomming connection.
-}
type alias Model =
    { counter : Int
    }


configDecoder : Json.Decode.Decoder Config
configDecoder =
    Json.Decode.map Config (Json.Decode.at [ "something" ] Json.Decode.string)



-- UPDATE


{-| Your custom message type.

The only restriction is that it has to contain an endpoint. You can call the
endpoint whatever you want, but it accepts no parameters, and must be provided
to the program as `endpoint` (see above).
-}
type Msg
    = Endpoint


update : Msg -> Conn -> ( Conn, Cmd Msg )
update msg conn =
    case msg of
        -- The endpoint signals the start of a new connection.
        -- You don't have to send a response right away, but we do here to
        -- keep the example simple.
        Endpoint ->
            Debug.log "conn: "
                conn
                |> statusCode Ok_200
                |> body (TextBody ("Got a request: " ++ conn.req.path))
                |> send responsePort



-- SUBSCRIPTIONS


port requestPort : Serverless.RequestPort msg


port responsePort : Serverless.ResponsePort msg


subscriptions : Conn -> Sub Msg
subscriptions _ =
    Sub.none
