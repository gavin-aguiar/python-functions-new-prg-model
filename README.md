## New programming model examples.

```python
import json
import azure.functions as func
import datetime
import logging

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)


@app.function_name(name="timertest")
@app.schedule(schedule="*/10 * * * * *", arg_name="dummy", run_on_startup=False,
              use_monitor=False)  # Timer Trigger
def timer_function(dummy: func.TimerRequest) -> None:
    utc_timestamp = datetime.datetime.utcnow().replace(
        tzinfo=datetime.timezone.utc).isoformat()

    if dummy.past_due:
        logging.info('The timer is past due!')

    logging.info('Python timer trigger function ran at %s', utc_timestamp)


@app.event_hub_message_trigger(arg_name="myhub", event_hub_name="inputhub",
                               connection="EHConnectionString")  # Eventhub trigger
@app.event_hub_output(arg_name="outputhub", event_hub_name="outputhub",
                             connection="EHConnectionString")  # Eventhub output binding
def event_hub_message_trigger(myhub: func.EventHubEvent, outputhub: func.Out[str]):
    outputhub.set("hello")


@app.queue_trigger(arg_name="msg", queue_name="inputqueue",
                   connection="storageAccountConnectionString")  # Queue trigger
@app.queue_output(arg_name="outputQueueItem", queue_name="outqueue",
                 connection="storageAccountConnectionString")  # Queue output binding
def queue_trigger(msg: func.QueueMessage,
                  outputQueueItem: func.Out[str]) -> None:
    logging.info('Python queue trigger function processed a queue item: %s',
                 msg.get_body().decode('utf-8'))
    outputQueueItem.set('hello')


@app.service_bus_topic_trigger(arg_name="serbustopictrigger",
                               topic_name="inputtopic",
                               connection="topicConnectionString",
                               subscription_name="testsub")  # service bus topic trigger
@app.service_bus_topic_output(arg_name="serbustopicbinding",
                             connection="outputtopicConnectionString",
                             topic_name="outputtopic",
                             subscription_name="testsub")  # service bus topic output binding
def service_bus_topic_trigger(serbustopictrigger: func.ServiceBusMessage,
         serbustopicbinding: func.Out[str]) -> None:
    logging.info('Python ServiceBus queue trigger processed message.')

    result = json.dumps({
        'message_id': serbustopictrigger.message_id,
        'body': serbustopictrigger.get_body().decode('utf-8'),
        'content_type': serbustopictrigger.content_type,
        'expiration_time': serbustopictrigger.expiration_time,
        'label': serbustopictrigger.label,
        'partition_key': serbustopictrigger.partition_key,
        'reply_to': serbustopictrigger.reply_to,
        'reply_to_session_id': serbustopictrigger.reply_to_session_id,
        'scheduled_enqueue_time': serbustopictrigger.scheduled_enqueue_time,
        'session_id': serbustopictrigger.session_id,
        'time_to_live': serbustopictrigger.time_to_live
    }, default=str)

    logging.info(result)
    serbustopicbinding.set("topic works!!")


@app.service_bus_queue_trigger(arg_name="serbustopictrigger",
                               queue_name="inputqueue",
                               connection="queueConnectionString")  # service bus queue trigger
@app.service_bus_queue_output(arg_name="serbustopicbinding",
                             connection="queueConnectionString",
                             queue_name="outputqueue")  # service bus queue output binding
def service_bus_queue_trigger(serbustopictrigger: func.ServiceBusMessage,
         serbustopicbinding: func.Out[str]) -> None:
    logging.info('Python ServiceBus queue trigger processed message.')

    result = json.dumps({
        'message_id': serbustopictrigger.message_id,
        'body': serbustopictrigger.get_body().decode('utf-8'),
        'content_type': serbustopictrigger.content_type,
        'expiration_time': serbustopictrigger.expiration_time,
        'label': serbustopictrigger.label,
        'partition_key': serbustopictrigger.partition_key,
        'reply_to': serbustopictrigger.reply_to,
        'reply_to_session_id': serbustopictrigger.reply_to_session_id,
        'scheduled_enqueue_time': serbustopictrigger.scheduled_enqueue_time,
        'session_id': serbustopictrigger.session_id,
        'time_to_live': serbustopictrigger.time_to_live
    }, default=str)

    logging.info(result)
    serbustopicbinding.set("queue works!!")


@app.cosmos_db_trigger(arg_name="triggerDocs", database_name="billdb",
                       collection_name="billcollection",
                       connection_string_setting="CosmosDBConnectionString",
                       lease_collection_name="leasesstuff",
                       create_lease_collection_if_not_exists="true")  # Cosmos DB Trigger
@app.cosmos_db_output(arg_name="outDoc", database_name="billdb",
                               collection_name="outColl",
                               connection_string_setting="CosmosDBConnectionString")  # Cosmos DB input binding
@app.cosmos_db_input(arg_name="inDocs", database_name="billdb",
                              collection_name="incoll",
                              connection_string_setting="CosmosDBConnectionString")  # Cosmos DB output binding
def cosmos_db_trigger(triggerDocs: func.DocumentList, inDocs: func.DocumentList,
         outDoc: func.Out[func.Document]) -> str:
    if triggerDocs:
        triggerDoc = triggerDocs[0]
        logging.info(inDocs[0]['text'])
        triggerDoc['ssss'] = 'Hello updated2!'
        outDoc.set(triggerDoc)


@app.blob_trigger(arg_name="triggerBlob", path="input-container/{name}",
                  connection="AzureWebJobsStorage")
@app.blob_output(arg_name="outputBlob", path="output-container/{name}",
                connection="AzureWebJobsStorage")
@app.blob_input(arg_name="readBlob", path="output-container/{name}",
               connection="AzureWebJobsStorage")
def blob_trigger(triggerBlob: func.InputStream, readBlob: func.InputStream,
                  outputBlob: func.Out[str]) -> None:
    logging.info(f"Blob trigger executed!")
    logging.info(f"Blob Name: {triggerBlob.name} ({triggerBlob.length}) bytes")
    logging.info(f"Full Blob URI: {triggerBlob.uri}")
    outputBlob.set('hello')
    logging.info(f"Output blob: {readBlob.read()}")


@app.event_grid_trigger(arg_name="eventGridEvent")
@app.event_grid_output(
    arg_name="outputEvent",
    topic_endpoint_uri="MyEventGridTopicUriSetting",
    topic_key_setting="MyEventGridTopicKeySetting")
def event_grid_trigger(eventGridEvent: func.EventGridEvent,
         outputEvent: func.Out[func.EventGridOutputEvent]) -> None:
    logging.info("eventGridEvent: ", eventGridEvent)

    outputEvent.set(
        func.EventGridOutputEvent(
            id="test-id",
            data={"tag1": "value1", "tag2": "value2"},
            subject="test-subject",
            event_type="test-event-1",
            event_time=datetime.datetime.utcnow(),
            data_version="1.0"))

# To run wsgi app using new prog model python function, please uncomment below section and comment out rest of file
# from flask import Flask, make_response, request
# flask_app = Flask(__name__)
# @flask_app.route("/")
# def index():
#     return (
#         "Try /hello/Chris for parameterized Flask route.\n"
#         "Try /module for module import guidance"
#     )

# @flask_app.route("/hello/<name>", methods=['GET','POST','DELETE'])
# def hello(name: str):
#     return f"hello {name}"
# app = func.FunctionApp(wsgi_app=flask_app.wsgi_app, auth_level=func.AuthLevel.ANONYMOUS)


# To run asgi app using new prog model python function, please uncomment below section and comment out rest of file
# import fastapi
# import json
# import mimesis
# from pydantic import BaseModel
# fast_app = fastapi.FastAPI()
# @fast_app.get("/hello")
# async def get_food(
#     name: str
# ):
#     return f"hello {name}"

# class FoodItem(BaseModel):
#     id: int
#     vegetable: str
#     dish: str
#     drink: str


# @fast_app.get("/hello")
# async def get_food(
#     name: str
# ):
#     return f"hello {name}"

# @fast_app.get("/food/{food_id}")
# async def get_food(
#     food_id: int,
# ):
#     food = mimesis.Food()
#     return {
#         "food_id": food_id,
#         "vegetable": food.vegetable(),
#         "dish": food.dish(),
#         "drink": food.drink(),
#     }


# @fast_app.post("/food/")
# async def create_food(food: FoodItem):
#     # Write the food item to the database here.
#     return food


# @fast_app.get("/users/{user_id}")
# async def read_item(user_id: int, locale: Optional[str] = None):
#     fake_user = mimesis.Person(locale=locale)
#     return {
#         "user_id": user_id,
#         "username": fake_user.username(),
#         "fullname": fake_user.full_name(),
#         "age": fake_user.age(),
#         "firstname": fake_user.first_name(),
#         "lastname": fake_user.last_name(),
#     }
# app = func.FunctionApp(asgi_app=fast_app, auth_level=func.AuthLevel.ANONYMOUS)
```
