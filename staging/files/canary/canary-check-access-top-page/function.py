from selenium import webdriver
import logging
import traceback
import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def top_page_monitoring():
    browser = webdriver.Chrome()
    browser.get('https://stg.app.vlayusuke.net/')  # Replace with the actual URL you want to check
    browser.save_screenshot(f'loaded_{datetime.datetime.now().strftime("%Y%m%d%H%M%S")}.png')
    browser.quit()

def canary_handler(event, context):
    try:
        logger.info("Starting Selenium script execution.")

        top_page_monitoring()

        logger.info("Selenium script executed successfully.")

        return {
            "statusCode": 200,
            "message": 'Completed top page monitoring.'
        }

    except Exception as e:
        logger.error(e)
        logger.error(traceback.format_exc())

        return {
            "statusCode": 500,
            "message": 'An error occurred at top page monitoring.'
        }
