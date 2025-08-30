import os
import uuid
from pyrogram import Client, filters
from pyrogram.types import InlineKeyboardButton, InlineKeyboardMarkup, CallbackQuery
import config

# Botun konfiqurasiyası
Rzayev = Client(
    "videoconvertor-bot",
    bot_token=config.BOT_TOKEN,
    api_id=config.API_ID,
    api_hash=config.API_HASH
)

# Yükləmə qovluğu
DOWNLOAD_LOCATION = os.environ.get("DOWNLOAD_LOCATION", "./DOWNLOADS/convert_mp3/")
os.makedirs(DOWNLOAD_LOCATION, exist_ok=True)

# Fayl məlumatlarını saxlamaq üçün qlobal lüğət
file_map = {}

# Thumbnail yolu (lokal)
THUMB_PATH = "assets/t.png"  # Burada öz thumbnail fayl yolunu əlavə et

# Başlanğıc mesajı
@Rzayev.on_message(filters.private & filters.text)
async def start(bot, message):
    await message.reply_sticker("CAACAgIAAxkDAAECdMZmp9GvSeZaqzMc8eOI3XOXVwM9kAACp0sAAkxU6EgAASZayQe46IoeBA")
    await message.reply_text("""Salam Dostum 🙋🏻!
⎋ Mən videoconvertor bot'am.
Videonu mp3/wav/ogg -a çevirmək üçün zəhmər olmasa mənə hər hansısa bir video göndərin!""")

# Video qəbul edildikdə işləyən funksiya
@Rzayev.on_message(filters.video & filters.private)
async def video_handler(bot, message):
    uid = str(uuid.uuid4())
    file_map[uid] = {"file_id": message.video.file_id, "status": "yüklənir"}

    keyboard = InlineKeyboardMarkup([
        [InlineKeyboardButton("🎵 MP3", callback_data=f"convert|{uid}|mp3"),
         InlineKeyboardButton("🎧 WAV", callback_data=f"convert|{uid}|wav"),
         InlineKeyboardButton("🎼 OGG", callback_data=f"convert|{uid}|ogg")]
    ])
    await message.reply_text("⚡ Format seç ⬇️", reply_markup=keyboard)

# Callback düyməsi basıldıqda işləyən funksiya
@Rzayev.on_callback_query()
async def callback_handler(bot, query: CallbackQuery):
    try:
        action, uid, format = query.data.split("|")
        file_info = file_map.get(uid)

        if not file_info:
            await query.answer("❌ Xəta baş verdi!", show_alert=True)
            return

        file_info["status"] = "çevrilir"
        await query.answer(f"🎧 {format.upper()} formatına çevrilir...", show_alert=True)

        file_path = os.path.join(DOWNLOAD_LOCATION, f"{uid}.{format}")
        await bot.download_media(file_info["file_id"], file_path)

        # Fayl göndərilir performer və thumbnail ilə
        await query.message.reply_audio(
            audio=file_path,
            caption=f"⚕️ {format.upper()} formatına cevrildi",
            performer="@corediii",  # performer (albom)
            thumb=THUMB_PATH,       # lokal thumbnail 
            quote=True
        )

        # Fayl silinir
        os.remove(file_path)
        del file_map[uid]

        # Mesaj yenilənir
        await query.edit_message_text(f"✅ {format.upper()} formatına çevrildi!")

    except Exception as e:
        await query.answer(f"❌ Xəta baş verdi: {str(e)}", show_alert=True)

# Botu işə salırıq
print("⚕️ Bot Aktivdir")
Rzayev.run()
