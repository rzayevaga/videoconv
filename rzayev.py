import os
from pyrogram import Client, filters
import config

DOWNLOAD_LOCATION = os.environ.get("DOWNLOAD_LOCATION", "./DOWNLOADS/")

Rzayev = Client(
    "videoconvm",
    bot_token = config.BOT_TOKEN,
    api_id = config.API_ID,
    api_hash = config.API_HASH
)

DOWNLOAD_LOCATION = os.environ.get("DOWNLOAD_LOCATION", "./DOWNLOADS/convert_mp3/")


@Rzayev.on_message(filters.private & filters.text)
async def start(bot, message):
    await message.reply_sticker("CAACAgIAAxkDAAECdMZmp9GvSeZaqzMc8eOI3XOXVwM9kAACp0sAAkxU6EgAASZayQe46IoeBA")
    await message.reply_text("""Salam Dostum 🙋🏻!
  ⎋ Mən videoconv bot'am.
  Videonu mp3'ə çevirmək üçün mənə hər hansısa bir video göndərin!""")

@Rzayev.on_message(filters.video & filters.private)
async def mp3(bot, message):
    
    # video servere yuklenir 
    file_path = DOWNLOAD_LOCATION + f"⚕ Rzayeff.mp3"
    txt = await message.reply_text("`Serverə yüklənir ⌛️...`")
    await message.download(file_path)
    await txt.edit_text("`Uğurla yükləndi ✅`")
    
    # mp3e çevrilir
    await txt.edit_text("`mp3'ə çevrilir ⌛️`")
    await message.reply_audio(audio=file_path, title="⎋  videoconvmbot", performer="Aga Rzayeff", caption="⚕: Uğurla çervrildi ☑️", quote=True)
    
    # fayl serverden silinir
    try:
        os.remove(file_path)
    except:
        pass
    
    await txt.delete()

print("⚕️ Bot Aktivdir")
Rzayev.run()
