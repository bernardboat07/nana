*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc. website
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             csv
Library             RPA.HTTP
Library             RPA.PDF
Library             RPA.Archive


*** Variables ***
${URL}=                 https://robotsparebinindustries.com/
${Order_Robot_URL}=     https://robotsparebinindustries.com/orders.csv


*** Tasks ***
Orders robots from RobotSpareBin Industries Inc. website
    Open robot order website
    Log in
    Download the csv file,open it, and close it
    Get Orders
    ${order}=    Set Variable
    Fill the order form using the data from the CSV file (${order})
    Collect orders (${Order_Robot_URL})
    Store the receipt as a PDF file
    screenshot of the robot
    ${screenshot}=    Set Variable
    Embed the robot screenshot to the receipt PDF file
    ${PDF_TEMP_OUTPUT_DIRECTORY}=    Set Variable
    Create a ZIP file of receipt PDF files (${PDF_TEMP_OUTPUT_DIRECTORY})
    [Teardown]    Log out and close the browser


*** Keywords ***
Open robot order website
    Open Available Browser    https://robotsparebinindustries.com/

log in
    Input Text    username    maria
    Input Password    password    thoushallnotpass
    Submit Form
    Wait Until Page Contains Element    id:order-form

Download the CSV file,open it, and close it
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Get Orders
    ${orders}=    Get orders
    FOR    ${order}    IN    @{orders}
        Log    ${orders}
    END

Fill and submit the form for one person
    [Arguments]    ${order}
    Click Button    css:#checkout
    Input Text    first-name    ${order["first_name"]}
    Input Text    last-name    ${order["last_name"]}
    Input Text    postal-code    ${order["zip"]}
    Click Button    Submit form
    Click Element When Visible    css:#finish

Read Worksheet As Table
    [Arguments]    ${header}

Open Workbook
    [Arguments]    ${OrderData.csv}
    ${order}=    Read Worksheet As Table    header=True

Close Workbook
    [Arguments]    ${Orders}
    FOR    ${order}    IN    @{Orders}
        Fill and submit the form for one person    ${order}
    END

Collect orders
    [Arguments]    ${Order_Robot_URL}
    Download    ${Order_Robot_URL}    overwrite=True
    ${orders}=    Get orders
    RETURN    ${orders}

Store the receipt as a PDF file
    Wait Until Element Is Visible    id:sales-results
    ${order_results_html}=    Get Element Attribute    id:sales-results    outerHTML
    Html To Pdf    ${order_results_html}    ${OUTPUT_DIR}${/}sales_results.pdf

screenshot of the robot

Screenshot css:div.sales-summary    ${OUTPUT_DIR}${/}sales_summary.png

Embed the robot screenshot to the receipt PDF file ${screenshot}

Create a ZIP file of receipt PDF files
    [Arguments]    ${PDF_TEMP_OUTPUT_DIRECTORY}
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}/PDFs.zip
    Archive Folder With Zip
    ...    ${PDF_TEMP_OUTPUT_DIRECTORY}
    ...    ${zip_file_name}

Log out and close the browser
    Click Button    Log out
    Close Browser
