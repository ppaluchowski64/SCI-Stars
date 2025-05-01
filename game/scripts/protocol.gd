class_name Protocol

func create_message(type, command, payload = null):
	if payload != null and typeof(payload) != TYPE_DICTIONARY:
		push_error("Payload must be a Dictionary or null")
		return null
	
	var message = {
		"type": type,
		"command": command,
		"payload": payload if payload != null else {}
	}
	
	return JSON.stringify(message, "", false) + "\n"

func parse_message(data):
	var json = JSON.new()
	var error = json.parse(data)
	
	if error != OK:
		push_error("Invalid JSON data")
		return null
	
	var message = json.get_data()
	
	if typeof(message) != TYPE_DICTIONARY:
		push_error("Parsed message must be a Dictionary")
		return null
	
	if not message.has("type") or not message.has("command") or not message.has("payload"):
		push_error("Message must contain 'type', 'command', and 'payload'")
		return null
	
	if typeof(message["payload"]) != TYPE_DICTIONARY:
		push_error("Payload must be a Dictionary")
		return null
	
	return message
