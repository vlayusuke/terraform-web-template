import asyncio
from selenium import webdriver
import logging
import traceback
import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

TIMEOUT = 30  # seconds


async def main():
    url = "https://stg.app.vlayusuke.com/"  # Replace with the actual URL you want to check
    browser = webdriver.Chrome()

    try:
        # Check if the page is navigated successfully
        def navigate_to_page():
            browser.implicitly_wait(TIMEOUT)
            browser.get(url)
            browser.save_screenshot(f'loaded_{datetime.datetime.now().strftime("%Y%m%d%H%M%S")}.png')

        await asyncio.to_thread(navigate_to_page)
        logger.info(f"Successfully navigated to {url}")

        # Click element with id "success" and check if the next page is loaded
        def actions_first_step():
            browser.find_element("xpath", '//h1[@id="success"]').click()
            browser.save_screenshot(f'loaded_{datetime.datetime.now().strftime("%Y%m%d%H%M%S")}.png')

        await asyncio.to_thread(actions_first_step)
        logger.info("Successfully performed actions on the first step.")

        # Check element exists on the next page to confirm navigation
        def actions_second_step():
            browser.find_element("xpath", '//h1[@id="success"]')
            browser.save_screenshot(f'loaded_{datetime.datetime.now().strftime("%Y%m%d%H%M%S")}.png')

        await asyncio.to_thread(actions_second_step)
        logger.info("Successfully performed actions on the second step.")

        # Check text of the element with id "success" on the next page
        def actions_third_step():
            browser.find_element("xpath", '//h1[@id="success"][contains(text(), "sample text")]')
            browser.save_screenshot(f'loaded_{datetime.datetime.now().strftime("%Y%m%d%H%M%S")}.png')

        await asyncio.to_thread(actions_third_step)
        logger.info("Successfully performed actions on the third step.")

        # Check Input text of the element with id "success" on the next page
        def actions_fourth_step():
            browser.find_element("xpath", '//h1[@id="success"]').send_keys("sample text")
            browser.save_screenshot(f'loaded_{datetime.datetime.now().strftime("%Y%m%d%H%M%S")}.png')

        await asyncio.to_thread(actions_fourth_step)
        logger.info("Successfully performed actions on the fourth step.")

        # Check clicking the element with id "success" on the next page
        def actions_fifth_step():
            browser.find_element("xpath", '//h1[@id="success"]').click()
            browser.save_screenshot(f'loaded_{datetime.datetime.now().strftime("%Y%m%d%H%M%S")}.png')

        await asyncio.to_thread(actions_fifth_step)
        logger.info("Successfully performed actions on the fifth step.")

        logger.info("Selenium script executed successfully.")
        browser.quit()

    except Exception as e:
        logger.error(e)
        logger.error(traceback.format_exc())
        browser.quit()

        return {
            "statusCode": 500,
            "message": 'An error occurred at check input top page monitoring.'
        }

async def canary_handler(event, context):
    logger.info("Starting Selenium script execution.")
    return await main()
