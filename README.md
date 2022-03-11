# python-functions-new-prg-model

## Sample function_app.py

```python
import json
import azure.functions as func
import datetime
import logging
import os

app = func.FunctionsApp()

@app.function_name(name="HttpTrigger1")
@app.route(route="hello") # HTTP Trigger
def test_function(req: func.HttpRequest) -> func.HttpResponse:
     return func.HttpResponse("HttpTrigger1 function processed a request!!!")


@app.function_name(name="HttpTrigger2")
@app.route(route="hello2") # HTTP Trigger
def test_function2(req: func.HttpRequest) -> func.HttpResponse:
     return func.HttpResponse("HttpTrigger2 function processed a request!!!")


@app.function_name(name="timertest")
@app.schedule(schedule="*/10 * * * * *", arg_name="dummy", run_on_startup=False,use_monitor=False) # Timer Trigger
def timer_function(dummy: func.TimerRequest) -> None:
    utc_timestamp = datetime.datetime.utcnow().replace(
        tzinfo=datetime.timezone.utc).isoformat()

    if dummy.past_due:
        logging.info('The timer is past due!')

    logging.info('Python timer trigger function ran at %s', utc_timestamp)


@app.function_name(name="EventHubFunc")
@app.on_event_hub_message(arg_name="myhub", event_hub_name="testhub", connection="EHConnectionString") # Eventhub trigger
@app.write_event_hub_message(arg_name="outputhub", event_hub_name="testhub", connection="EHConnectionString") # Eventhub output binding
def eventhub_trigger(myhub: func.EventHubEvent, outputhub: func.Out[str]):
    outputhub.set("hello")


@app.function_name(name="QueueFunc")
@app.on_queue_change(arg_name="msg", queue_name="js-queue-items", connection="storageAccountConnectionString") # Queue trigger
@app.write_queue(arg_name="outputQueueItem", queue_name="outqueue", connection="storageAccountConnectionString") # Queue output binding
def test_function(msg: func.QueueMessage, outputQueueItem: func.Out[str]) -> None:
    logging.info('Python queue trigger function processed a queue item: %s',
                 msg.get_body().decode('utf-8'))
    outputQueueItem.set('hello')


@app.function_name(name="ServiceBusTopicFunc")
@app.on_service_bus_topic_change(arg_name="serbustopictrigger", topic_name="testtopic", connection="topicConnectionString", subscription_name="testsub") # service bus topic trigger
@app.write_service_bus_topic(arg_name="serbustopicbinding", connection="outputtopicConnectionString",  topic_name="outputtopic", subscription_name="testsub") # service bus topic output binding 
def main(serbustopictrigger: func.ServiceBusMessage, serbustopicbinding: func.Out[str]) -> None:
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


@app.function_name(name="ServiceBusQueueFunc")
@app.on_service_bus_queue_change(arg_name="serbustopictrigger", queue_name="inputqueue", connection="queueConnectionString") # service bus queue trigger
@app.write_service_bus_queue(arg_name="serbustopicbinding", connection="queueConnectionString",  queue_name="outputqueue")  # service bus queue output binding 
def main(serbustopictrigger: func.ServiceBusMessage, serbustopicbinding: func.Out[str]) -> None:
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


@app.function_name(name="Cosmos1")
@app.on_cosmos_db_update(arg_name="triggerDocs", database_name="billdb", collection_name="billcollection", connection_string_setting="CosmosDBConnectionString",
 lease_collection_name="leasesstuff", create_lease_collection_if_not_exists="true") # Cosmos DB Trigger
@app.write_cosmos_db_documents(arg_name="outDoc", database_name="billdb", collection_name="outColl", connection_string_setting="CosmosDBConnectionString") # Cosmos DB input binding
@app.read_cosmos_db_documents(arg_name="inDocs", database_name="billdb", collection_name="incoll", connection_string_setting="CosmosDBConnectionString") # Cosmos DB output binding
def main(triggerDocs: func.DocumentList, inDocs: func.DocumentList, outDoc: func.Out[func.Document]) -> str:
    if triggerDocs:
        triggerDoc = triggerDocs[0]
        logging.info(inDocs[0]['text'])
        triggerDoc['ssss'] = 'Hello updated2!'
        outDoc.set(triggerDoc)
```
