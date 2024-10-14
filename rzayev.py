import os
from pyrogram import Client, filters


DOWNLOAD_LOCATION = os.environ.get("DOWNLOAD_LOCATION", "./DOWNLOADS/")

Rzayev = Client(
    "videoconvmusic",
    bot_token = "7287137375:AAF9RbA4ZQLfnS0c7_V4mo54qsV4r-tGpfM",
    api_id = "18052289",
    api_hash = "552525f45a3066fee54ca7852235c19c"
)

DOWNLOAD_LOCATION = os.environ.get("DOWNLOAD_LOCATION", "./DOWNLOADS/conert_mp3/")


@Rzayev.on_message(filters.private & filters.text)
async def start(bot, message):
    await message.reply_sticker("CAACAgIAAxkDAAECdMZmp9GvSeZaqzMc8eOI3XOXVwM9kAACp0sAAkxU6EgAASZayQe46IoeBA")
    await message.reply_text("""Salam Dostum 🙋🏻!
  ⎋ Mən videoconvmusic bot'am.
  Videonu mp3'ə çevirmək üçün mənə video göndərin!""")

@Rzayev.on_message(filters.video & filters.private)
async def mp3(bot, message):
    
    # download video
    file_path = DOWNLOAD_LOCATION + f"⚕ aiteknoloji.mp3"
    txt = await message.reply_text("`Serverə yüklənir ⌛️...`")
    await message.download(file_path)
    await txt.edit_text("`Uğurla yükləndi ✅`")
    
    # convert to audio
    await txt.edit_text("`mp3'ə çevrilir ⌛️`")
    await message.reply_audio(audio=file_path, title="⎋  videoconvmusicbot", performer="@aitbots", caption="⚕ aiteknoloji: Uğurla çervrildi ☑️", quote=True)
    
    # remove file
    try:
        os.remove(file_path)
    except:
        pass
    
    await txt.delete()

print("Bot Aktivdir...")
Rzayev.run()
