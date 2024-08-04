

import gradio as gr
from utils import archive, recognize, post_records, check_db, get_records_from_db, send_email, smile_with_interval, detect_face_smile, generate_joke
import plotly.express as px
import threading


message = "Why was the data scientist sad? Because he had too many missing values in his life!"

def update_message():
    global message
    message = generate_joke()
    threading.Timer(10, update_message).start()

update_timer = threading.Timer(0, update_message)
update_timer.start()


# PLOTLY

def generate_plots():
    df = get_records_from_db()

    if df.empty:
        return None, None, None, None, None

    df['Hour'] = df['Time'].dt.hour
    hourly_counts = df.groupby('Hour').size().reset_index(name='Counts')
    fig_hourly = px.bar(hourly_counts, x='Hour', y='Counts', title='Hourly Entrances', labels={'Hour': 'Hour', 'Counts': 'Entrances'})
    
    df['Date'] = df['Time'].dt.date
    daily_counts = df.groupby('Date').size().reset_index(name='Counts')
    fig_daily = px.bar(daily_counts, x='Date', y='Counts', title='Daily Entrances', labels={'Date': 'Date', 'Counts': 'Entrances'})

    df['Week'] = df['Time'].dt.weekday
    weekly_counts = df.groupby('Week').size().reset_index(name='Counts')
    fig_weekly = px.bar(weekly_counts, x='Week', y='Counts', title='Weekly Entrances', labels={'Week': 'Week', 'Counts': 'Entrances'})

    df['Month'] = df['Time'].dt.month
    monthly_counts = df.groupby('Month').size().reset_index(name='Counts')
    fig_monthly = px.bar(monthly_counts, x='Month', y='Counts', title='Monthly Entrances', labels={'Month': 'Month', 'Counts': 'Entrances'})

    df['Year'] = df['Time'].dt.year
    yearly_counts = df.groupby('Year').size().reset_index(name='Counts')
    fig_yearly = px.bar(yearly_counts, x='Year', y='Counts', title='Yearly Entrances', labels={'Year': 'Year', 'Counts': 'Entrances'})

    return fig_hourly, fig_daily, fig_weekly, fig_monthly, fig_yearly

def refresh_plots():
    fig_hourly, fig_daily, fig_weekly,fig_monthly, fig_yearly = generate_plots()
    return fig_hourly, fig_daily, fig_weekly,fig_monthly, fig_yearly


# GRADIO INTERFACE UTILS #
def clear_recognition_output():
    return gr.update(value=None) 

def clear_add_person_panel():
    return gr.update(value=""), gr.update(value=""), gr.update(value=None)

def update_monitoring_table():
    records = get_records_from_db()
    return records


def process_recognition_output(output):
    if "Matches" in output and output["Matches"]:
        source_image = output["Matches"][0]["SourceImage"]
        name_parts = source_image.split("_")
        if len(name_parts) >= 2:
            full_name_out = name_parts[0].capitalize() + " " + name_parts[1].split(".")[0].capitalize()
            first_name_db = name_parts[0].lower()
            last_name_db = name_parts[1].split(".")[0].lower()
            return f'<p style="color: green; font-size: 36px; font-weight: bold;">Welcome {full_name_out}. Have a nice day :)</p>', first_name_db, last_name_db
        else:
            return '<p style="color: red; font-size: 36px; font-weight: bold;">You do not have access permission.</p>', False, False
    else:
        return '<p style="color: red; font-size: 36px; font-weight: bold;">You do not have access permission.</p>', False, False

    

def handle_image_change(image_path):
    
    global message
    
    if image_path:
        
        face_smile = detect_face_smile()
        if face_smile:
            
            recognition_result = recognize()
            processed_output,firstname, lastname = process_recognition_output(recognition_result)
            
            if check_db():
                if firstname or lastname:
                    post_records(firstname, lastname)
                    send_email(firstname.capitalize(), lastname.capitalize())

            return processed_output 
        else:
            return f'<p style="color: yellow; font-size: 36px; font-weight: bold;">{message}</p>'         
    
    else:
        return clear_recognition_output()



with gr.Blocks() as app:
    gr.Markdown("# SMILE app v1.0.0")
            
    with gr.Tab("Camera"):
        gr.Markdown("Your Smile is your password :)")
        
        with gr.Row():
            
            with gr.Column(scale=2):  
                image_input = gr.Image(type="filepath", sources="webcam", streaming=True, height=494, width=800)
            with gr.Column(scale=1): 
                recognize_output = gr.HTML(label="Recognition Output")
            
        #upload_output = gr.Textbox(label="Upload Output")
          

        image_input.change(smile_with_interval, inputs=[image_input])\
            .then(handle_image_change, inputs=[image_input], outputs=recognize_output)
        
    with gr.Tab("Add person"):
        gr.Markdown("Person register area")

        with gr.Column():
            first_name_input = gr.Textbox(label="Firstname", placeholder="Firstname")
            last_name_input = gr.Textbox(label="Lastname", placeholder="Lastname")
            file_input = gr.File(file_count="single", type="filepath", label="Upload Images")
            load_output = gr.Textbox(label="Load Class Output")
            load_button = gr.Button("Add person to the system")
            load_button.click(archive, inputs=[file_input, first_name_input, last_name_input], outputs=load_output)\
                .then(clear_add_person_panel, outputs=[first_name_input, last_name_input, file_input])
                
    with gr.Tab("Monitor Entrances"):
        gr.Markdown("Monitor the entrances")

        # Db records
        table = gr.DataFrame(value=update_monitoring_table(), label="Entrance Records", type="pandas")
        refresh_button = gr.Button("Refresh Table")
        
        # Graphs
        plot_hourly = gr.Plot(label="Hourly Entrances")
        plot_daily = gr.Plot(label="Daily Entrances")
        plot_weekly = gr.Plot(label="Weekly Entrances")
        plot_monthly = gr.Plot(label="Monthly Entrances")
        plot_yearly = gr.Plot(label="Yearly Entrances")
        
        refresh_button.click(update_monitoring_table, outputs=table)\
            .then(refresh_plots, outputs=[plot_hourly, plot_daily, plot_weekly,plot_monthly, plot_yearly]) 
              
            

if __name__ == "__main__":
    send_email("send", "verification")
    post_records("initialize", "database")
    app.launch(server_name="0.0.0.0")
    
    
    
    
