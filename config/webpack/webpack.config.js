const path = require("path");
const { generateWebpackConfig } = require("shakapacker");

const webpackConfig = generateWebpackConfig();

if (!webpackConfig) {
  throw new Error("generateWebpackConfig did not return a valid configuration. Check your Shakapacker setup.");
}

const sassRule = webpackConfig.module.rules.find((rule) =>
  rule.use?.some((loader) => loader.loader?.includes("sass-loader"))
);

const sassLoader = sassRule?.use?.find((loader) => loader.loader?.includes("sass-loader"));

if (sassLoader?.options?.api === "modern") {
  const sassOptions = sassLoader.options.sassOptions || {};
  const includePaths = sassOptions.includePaths || [];

  if (includePaths.length > 0 && !sassOptions.loadPaths) {
    sassLoader.options.sassOptions = {
      ...sassOptions,
      loadPaths: includePaths.map((loadPath) => path.resolve(loadPath))
    };

    delete sassLoader.options.sassOptions.includePaths;
  }
}

module.exports = webpackConfig;
