// Specific mechanics of the shader-saver page.

var image = `
    void mainImage( out vec4 fragColor, in vec2 fragCoord ) {  
        vec2 uv = fragCoord.xy / iResolution.xy;
        vec4 col = texture(iChannel0, uv);
        fragColor = vec4(col.rgb, 1.);
    }
`;

/**
 * Create a canvas element without attaching it to the webpage.
 * @param {*} canvasId The ID the created canvas will be given.
 * @returns The canvas DOM element.
 */
function createCanvas(canvasId) {
    var offScreenCanvas = document.createElement('canvas');
    offScreenCanvas.id = canvasId;
    offScreenCanvas.width = outputConfiguration.width;
    offScreenCanvas.height = outputConfiguration.height;
    return offScreenCanvas;
}

/**
 * Configure a canvas.
 * @param {*} canvas DOM element of the canvas to configure.
 */
function configureCanvas(canvas) {
    try {
        // set up and play the shader
        const toy = new ShaderToyLite(canvas);
        toy.setCommon('');
        toy.setBufferA({ source: shaderConfiguration.source });
        toy.setImage({ source: image, iChannel0: 'A' });
        toy.play();
        setPreviewMessage("Successful Configuration.", "green");
    } catch (reason) {
        setPreviewMessage(reason, "red");
    }
}

/**
 * Get names of output files to be downloaded.
 */
function getFilename() {
    const date = new Date();
    const dateString = [
        date.getFullYear(),
        date.getMonth(),
        date.getDate(),
        date.getHours(),
        date.getMinutes(),
        date.getSeconds(),
    ].join("-");
    return `output-${dateString}.png`;
}

var shaderConfiguration = {
    source: undefined,
    error: undefined,
};

function setShaderConfiguration(newShaderConfiguration) {
    shaderConfiguration = {
        ...shaderConfiguration,
        ...newShaderConfiguration,
    };

    if (shaderConfiguration.error !== undefined) {
        setPreviewMessage(shaderConfiguration.error, "red");
    }

    const previewCanvas = document.getElementById("preview_canvas");
    configureCanvas(previewCanvas);
}

// Apply changes to the shader file
listenTo({
    elementId: "shader_file_input",
    onValue: (target) => {
        const files = target.files;

        // make sure a file exists
        if (files.length == 0) {
            setShaderConfiguration({
                source: undefined,
                error: "No Files Given.",
            });
            return;
        }

        // Read the file as text
        readFile(files[0]).then((fileContents) => {
            setShaderConfiguration({
                source: fileContents,
                error: undefined,
            });
        }).catch((reason) => {
            setShaderConfiguration({
                error: "Failed to Read File",
            });
        });
    },
});

var outputConfiguration = {
    width: undefined,
    height: undefined,
    saveOutput: undefined,
};

function setOutputConfiguration(newOutputConfigurations) {
    outputConfiguration = {
        ...outputConfiguration,
        ...newOutputConfigurations,
    };

    // TODO update UI?
}

// Apply changes to output image width
listenTo({
    elementId: "width_input",
    onValue: (target) => {
        const newWidth = target.valueAsNumber;
        setOutputConfiguration({
            width: newWidth,
        });
    },
});

// Apply changes to output image width
listenTo({
    elementId: "height_input",
    onValue: (target) => {
        const newHeight = target.valueAsNumber;
        setOutputConfiguration({
            height: newHeight,
        });
    },
});

listenTo({
    elementId: "save_output_input",
    onValue: (target) => {
        const newSaveOutput = target.checked;
        console.log(newSaveOutput);
        setOutputConfiguration({
            saveOutput: newSaveOutput,
        });
    },
});

// Generate output when the button is pressed
listenTo({
    elementId: "generate_image_button",
    onClick: (target) => {

        const canvas = createCanvas("output-canvas");
        canvas.width = outputConfiguration.width;
        canvas.height = outputConfiguration.height;
        configureCanvas(canvas);

        setTimeout(() => {
            const dataURL = canvas.toDataURL("image/png", 0.5);

            const filename = getFilename();

            const image = document.getElementById('output_image');
            image.src = dataURL;

            if (outputConfiguration.saveOutput) {
                // // Create a link element and trigger a download
                const downloadLink = document.createElement('a');
                downloadLink.href = dataURL;
                downloadLink.download = filename;
                downloadLink.click();
                setOutputMessage(`Started Download of [${filename}].`, "green");
            }
        }, 1000);
    },
});
