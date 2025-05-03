import asyncio
import json

from question_engine import QuestionEngine
from message_handler import MessageHandler


class QuestionServer:
    def __init__(self, host='0.0.0.0', port=12345, db_path='questions.db'):
        self.host = host
        self.port = port
        self.engine = QuestionEngine(db_path)
        self.handler = MessageHandler()

    async def handle_client(self, reader, writer):
        address = writer.get_extra_info('peername')
        print("[Question] Connected to", address)

        try:
            while True:
                data = await reader.readline()
                if not data:
                    break

                message = data.decode('utf-8').strip()
                print("[Question] Received from", address)

                try:
                    request = self.handler.parse_message(message)

                except (json.JSONDecodeError, ValueError, TypeError) as e:
                    response = self.handler.create_message(
                        "response", "error", {"message": str(e)}
                    )

                else:
                    if request.get("command") == "get_random_question":
                        question_text = self.engine.get_random_question()
                        question_id = self.engine.get_question_id(question_text)
                        answers = self.engine.get_answers(question_id)

                        response = self.handler.create_message(
                            "response", "get_random_question", {
                                "question_id": question_id,
                                "question": question_text,
                                "answers": answers
                            }
                        )

                    elif request.get("command") == "submit_answer":
                        question_id = request.get("payload", {}).get("question_id")
                        answer = request.get("payload", {}).get("answer")
                        is_correct = self.engine.check_answer(question_id, answer)
                        correct_answer = self.engine.get_correct_answer(question_id)

                        response = self.handler.create_message(
                            "response", "submit_answer", {
                                "correct": is_correct,
                                "correct_answer": correct_answer
                            }
                        )

                    else:
                        response = self.handler.create_message(
                            "response", "error", {"message": "Unknown command"}
                        )

                writer.write(response.encode('utf-8'))
                await writer.drain()
                print("[Question] Sent to", address)

        except Exception as error:
            print("[Question] Error:", error)

        finally:
            writer.close()
            await writer.wait_closed()
            print("[Question] Disconnected from", address)

    async def start(self):
        server = await asyncio.start_server(self.handle_client, self.host, self.port)
        print("[Question] Listening on", server.sockets[0].getsockname())

        async with server:
            await server.serve_forever()


if __name__ == "__main__":
    question_server = QuestionServer()
    asyncio.run(question_server.start())
