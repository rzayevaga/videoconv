import os
import asyncio
from pyrogram import Client, filters
from pyrogram.types import InlineKeyboardMarkup, InlineKeyboardButton, CallbackQuery
import config

Rzayev = Client(
    "videoconvm",
    bot_token=config.BOT_TOKEN,
    api_id=config.API_ID,
    api_hash=config.API_HASH
)

DOWNLOAD_LOCATION = os.environ.get("DOWNLOAD_LOCATION", "./DOWNLOADS/convert_audio/")
os.makedirs(DOWNLOAD_LOCATION, exist_ok=True)

# Başlanğıc mesajı
@Rzayev.on_message(filters.private & filters.text)
async def start(bot, message):
    await message.reply_sticker("CAACAgIAAxkDAAECdMZmp9GvSeZaqzMc8eOI3XOXVwM9kAACp0sAAkxU6EgAASZayQe46IoeBA")
    await message.reply_text(
        """Salam Dostum 🙋🏻!
⎋ Mən **videoconv bot**'am.  
Videonu musiqi fayllarına çevirmək üçün sadəcə video göndər 👇"""
    )

# Video gələndə seçim menyusu
@Rzayev.on_message(filters.video & filters.private)
async def video_handler(bot, message):
    keyboard = InlineKeyboardMarkup(
        [[
            InlineKeyboardButton("🎵 MP3", callback_data="to_mp3"),
            InlineKeyboardButton("🎧 OGG", callback_data="to_ogg")
        ],[
            InlineKeyboardButton("🎼 WAV", callback_data="to_wav"),
            InlineKeyboardButton("📀 FLAC", callback_data="to_flac")
        ]]
    )
    await message.reply_text(
        "⚡ Format seç ⬇️",
        reply_markup=keyboard
    )
    message.continue_propagation()

# Realistik progress bar
async def realistic_progress(txt_message, total_size, prefix="Yüklənir"):
    steps = 20
    uploaded = 0
    for i in range(1, steps + 1):
        percent = (i / steps)
        uploaded_size = int(total_size * percent)
        bar = "⬛" * i + "⬜" * (steps - i)
        await txt_message.edit_text(f"`{prefix}... [{bar}] {int(percent*100)}%`")
        # delay nisbətən fayl ölçüsünə uyğun
        await asyncio.sleep(max(0.1, total_size / (1024*1024*5)))  # 5MB base delay

# Callback işləyir (format seçimi)
@Rzayev.on_callback_query()
async def callback_handler(bot, query: CallbackQuery):
    format_type = query.data.replace("to_", "")
    video = query.message.reply_to_message.video

    txt = await query.message.reply_text("`Serverə yüklənir...`")

    # Fayl yüklənir
    file_path = os.path.join(DOWNLOAD_LOCATION, f"Rzayeff.{format_type}")
    await bot.download_media(video.file_id, file_path)

    # Fayl ölçüsü
    file_size = os.path.getsize(file_path)

    # Progress bar animasiyası
    await realistic_progress(txt, total_size=file_size, prefix=f"{format_type.upper()} hazırlanır")

    # Fayl göndərilir
    await bot.send_audio(
        chat_id=query.message.chat.id,
        audio=file_path,
        title="⎋  videoconvmbot",
        performer="Aga Rzayeff",
        caption=f"⚕: Uğurla {format_type.upper()} formatına çevrildi ☑️",
        quote=True
    )

    # Fayl silinir
    try:
        os.remove(file_path)
    except:
        pass

    await txt.delete()
    await query.answer("✅ Hazırdır!")

print("⚕️ Bot Aktivdir")
Rzayev.run()
