#!/usr/bin/env python3

def process_file(filepath):
    import pandas as pd
    import re
    # Initialize empty dataframes
    compose_up_df = pd.DataFrame(columns=['run', 'time'])
    compose_stop_df = pd.DataFrame(columns=['run', 'time'])
    service_up_df = pd.DataFrame(columns=['run', 'time'])
    warmup_df = pd.DataFrame(columns=['request', 'run', 'time'])
    memory_df = pd.DataFrame(columns=['request', 'run', 'mem'])
    load_df = pd.DataFrame(columns=['run', 'freq'])

    print('processing file', filepath)
    with open(filepath, 'r') as file:
        for line in file:
            # Split the line into operation, run, and time
            operation, run, request, value = line.split(' - ')

            # Remove the 'seconds' from the time and convert it to float
            run = int(run)
            request = int(request)
            if 'seconds' in value:
              time = float(value.replace(' seconds\n', ''))

            # Depending on the operation, append the time to the relevant dataframe
            if 'compose up app' in operation:
                compose_up_df = compose_up_df.append({'run': run, 'time': time}, ignore_index=True)
            elif 'compose stop app' in operation:
                compose_stop_df = compose_stop_df.append({'run': run, 'time': time}, ignore_index=True)
            elif 'service up' in operation:
                service_up_df = service_up_df.append({'run': run, 'time': time}, ignore_index=True)
            elif 'warmup request' in operation:
                warmup_df = warmup_df.append({'run': run, 'request': request, 'time': time}, ignore_index=True)
            elif 'memory' in operation:
                match = re.search(r"app-1\s*(\d+\.\d+)MiB\s*/", value)
                if match:
                    memory_df = memory_df.append({'run': run, 'request': request, 'mem': float(match.group(1))}, ignore_index=True)
            elif 'throughput' in operation:
                match = re.search(r"(\d+\.\d+)\s*req/sec", value)
                connections = request
                if match:
                    load_df = load_df.append({'run': run, 'connections': connections, 'freq': float(match.group(1))}, ignore_index=True)

    # Calculate mean and standard deviation for each request
    warmup_summary_df = warmup_df.groupby('request')['time'].agg(['mean', 'std'])

    return compose_up_df, compose_stop_df, service_up_df, warmup_summary_df, memory_df, load_df

def plot_data(dataframes):
    import matplotlib.pyplot as plt
    import matplotlib.gridspec as gridspec
    # Create figure and specify gridspec
    fig = plt.figure(figsize=(12, 30))
    gs = gridspec.GridSpec(6, 1, height_ratios=[1, 1, 1, 1, 1, 1]) 

    ax0 = plt.subplot(gs[0])
    ax1 = plt.subplot(gs[1])
    ax2 = plt.subplot(gs[2])
    ax3 = plt.subplot(gs[3])
    ax4 = plt.subplot(gs[4])
    ax5 = plt.subplot(gs[5])

    ax = [ax0, ax1, ax2, ax3, ax4, ax5]

    # Create a colormap
    colormap = plt.get_cmap('tab10')

    # Plot compose restart times and service up times
    for i, (filename, dfs) in enumerate(sorted(dataframes.items(), key=lambda x: x[0])):
        print('plotting file', filename)
        color = colormap(i)  # Get a color from the colormap

        # Plot service up times
        rects1 = ax[0].bar(str(i), dfs['service_up']['time'].mean(), yerr=dfs['service_up']['time'].std(), color=color, label=filename)
        autolabel(rects1, ax[0])

        # Plot first request time
        rects2 = ax[1].bar(str(i), dfs['warmup_summary'].loc[1, 'mean'], yerr=dfs['warmup_summary'].loc[1, 'std'], color=color, label=filename)
        autolabel(rects2, ax[1])

        # Plot warmup request times with full range
        ax[2].plot(dfs['warmup_summary'].index, dfs['warmup_summary']['mean'], color=color, label=filename)
        ax[2].errorbar(dfs['warmup_summary'].index, dfs['warmup_summary']['mean'], yerr=dfs['warmup_summary']['std'], color=color, alpha=0.4, fmt='none')
        ax[2].set_xlim(0.5, 5.5)

        # Plot warmup request times with restricted range
        ax[3].plot(dfs['warmup_summary'].index, dfs['warmup_summary']['mean'], color=color, label=filename)
        ax[3].errorbar(dfs['warmup_summary'].index, dfs['warmup_summary']['mean'], yerr=dfs['warmup_summary']['std'], color=color, alpha=0.4, fmt='none')
        ax[3].set_ylim(0, 0.4)

        # Plot throughput
        filtered_df = dfs['throughput'][dfs['throughput']['connections'] == 10]
        rects3 = ax[4].bar(str(i), filtered_df['freq'].mean(), yerr=filtered_df['freq'].std(), color=color, label=filename)
        autolabel(rects3, ax[4])

        # Plot Memory
        rects4 = ax[5].bar(str(i), dfs['memory']['mem'].mean(), yerr=dfs['memory']['mem'].std(), color=color, label=filename)
        autolabel(rects4, ax[5])

    fig.suptitle('Constrained Resource Performance Analysis', fontsize=20)

    ax[0].set_title('Service Up Times')
    ax[0].set_xlabel('Type')
    ax[0].set_ylabel('Time (seconds)')
    #ax[0].legend(loc='upper right')
    ax[0].legend(loc='best')

    ax[1].set_title('Warmup Request Times - First')
    ax[1].set_xlabel('Type')
    ax[1].set_ylabel('Time (seconds)')
    #ax[1].legend(loc='upper right')
    ax[1].legend(loc='best')

    ax[2].set_title('Warmup Request Times - Full Range')
    ax[2].set_xlabel('Request Number')
    ax[2].set_ylabel('Time (seconds)')
    #ax[2].legend(loc='upper right')
    ax[2].legend(loc='best')

    ax[3].set_title('Warmup Request Times - Restricted Range')
    ax[3].set_xlabel('Request Number')
    ax[3].set_ylabel('Time (seconds)')
    #ax[3].legend(loc='upper right')
    ax[3].legend(loc='best')

    ax[4].set_title('Throughput')
    ax[4].set_xlabel('Type')
    ax[4].set_ylabel('Req/s')
    #ax[4].legend(loc='lower right')
    ax[4].legend(loc='best')

    ax[5].set_title('Memory')
    ax[5].set_xlabel('Type')
    ax[5].set_ylabel('MiB')
    #ax[5].legend(loc='lower right')
    ax[5].legend(loc='best')

    plt.subplots_adjust(top=0.95, bottom=0.05, hspace=0.3)
    #plt.subplots_adjust(bottom=0.2)  # make more space at the bottom for the legend

    return plt

def autolabel(rects, ax):
    """Attach a text label above each bar in *rects*, displaying its height."""
    for rect in rects:
        height = rect.get_height()
        ax.annotate('{}'.format(round(height, 2)),
                    xy=(rect.get_x() + rect.get_width() / 2, height),
                    xytext=(0, 3),  # 3 points vertical offset
                    textcoords="offset points",
                    ha='center', va='bottom')
        
def load_file_into_dataframes(pattern):
    import glob

    # Dictionary to store dataframes
    dataframes = {}

    # Loop through the matched files
    for file in glob.glob(pattern, recursive=True):
        if 'requirements.txt' in file: continue
        if 'old/' in file: continue
        # Process file and store dataframes in dictionary
        compose_up_df, compose_stop_df, service_up_df, warmup_summary_df, memory_df, load_df = process_file(file)
        dataframes[file.replace('.txt', '')] = {
            'compose_up': compose_up_df,
            'compose_stop': compose_stop_df,
            'service_up': service_up_df,
            'warmup_summary': warmup_summary_df,
            'memory': memory_df,
            'throughput': load_df,
        }

    return dataframes

def main():
    import sys
    # Check that a command line argument was provided
    if len(sys.argv) < 2:
        print('Usage: python script.py <pattern> <output>')
        sys.exit(1)

    # The first command line argument is the glob pattern
    input = sys.argv[1].replace('/','')
    pattern_a = '**/'+input+'.txt';
    pattern_b = input+'/*.txt'

    # Load data
    dataframes_a = load_file_into_dataframes(pattern_a)
    dataframes_b = load_file_into_dataframes(pattern_b)

    # Plot data
    plot = plot_data({**dataframes_a, **dataframes_b})
    plot.savefig(input+'.png')

if __name__ == '__main__':
    main()