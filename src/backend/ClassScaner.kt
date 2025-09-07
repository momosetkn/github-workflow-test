package momosetkn.maigreko.util

import java.net.JarURLConnection
import java.net.URL
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths
import java.util.Enumeration

class ClassScanner(
    private val cl: ClassLoader = Thread.currentThread().contextClassLoader
) {
    @Suppress("NestedBlockDepth")
    fun listClassesByPackageRecursively(packageName: String): List<String> {
        val path = packageName.replace('.', '/') + '/'
        val resources = cl.getResources(path)
        val result = mutableListOf<String>()

        val rootUrls = rootURLs()

        val rootUrl = rootUrls.firstOrNull() ?: return result
        when (rootUrl.protocol) {
            "file" ->
                searchAndAppendFromFiles(
                    resources = resources,
                    result = result,
                    rootPaths = rootUrls.map { Paths.get(it.toURI()) },
                )
            "jar" ->
                searchAndAppendFromJar(
                    resources = resources,
                    path = path,
                    result = result
                )
        }

        return result
    }

    private fun rootURLs(): MutableList<URL> {
        val roots = cl.getResources("")
        val rootUrls = mutableListOf<URL>()
        while (roots.hasMoreElements()) {
            val rootUrl = roots.nextElement()
            rootUrls += rootUrl
        }
        return rootUrls
    }

    @Suppress("NestedBlockDepth")
    private fun searchAndAppendFromFiles(
        resources: Enumeration<URL>,
        result: MutableList<String>,
        rootPaths: List<Path>,
    ) {
        while (resources.hasMoreElements()) {
            val url = resources.nextElement()
            val dir = Paths.get(url.toURI())
            Files.walk(dir).use { stream ->
                stream
                    .filter { Files.isRegularFile(it) }
                    .forEach { file ->
                        rootPaths.forEach { rootPath ->
                            if (file.startsWith(rootPath)) {
                                appendIfTarget(file.toString(), result) {
                                    rootPath.relativize(file).toString()
                                }
                            }
                        }
                    }
            }
        }
    }

    private fun searchAndAppendFromJar(
        resources: Enumeration<URL>,
        path: String,
        result: MutableList<String>,
    ) {
        while (resources.hasMoreElements()) {
            val url = resources.nextElement()
            val conn = url.openConnection() as JarURLConnection
            val jar = conn.jarFile
            for (entry in jar.entries()) {
                if (entry.name.startsWith(path) && !entry.isDirectory) {
                    appendIfTarget(entry.name, result)
                }
            }
        }
    }

    private fun appendIfTarget(s: String, result: MutableList<String>, transform: (String) -> String = { it }) {
        if (s.endsWith(SUFFIX)) {
            val relative = s
                .removePrefix("/")
                .let { transform(it) }
            val className = relative
                .removeSuffix(SUFFIX)
                .replace('/', '.')
                .replace('\\', '.') // windows
            result.add(className)
        }
    }

    companion object {
        const val SUFFIX = ".class"
    }
}
