public class ContainerFactory {
    private var sources: [NSURL]
    private var loader: Loader
    private var plugins: [AnyClass]
 
    public init(sources: [NSURL], loader: Loader) {
        self.sources = sources
        self.loader = loader
        self.plugins = loader.containerPlugins.filter({ $0 is UIContainerPlugin.Type })
    }
    
    public func createContainers() -> [Container] {
        return sources.flatMap(createContainer).map(addPlugins)
    }
    
    private func createContainer(url: NSURL) -> Container? {
        let availablePlaybacks = loader.playbackPlugins.filter({type in canPlay(type, url:url)})
        
        if availablePlaybacks.count == 0 {
            return nil
        }
        
        let type = availablePlaybacks[0] as! Playback.Type
        return Container(playback: type.init(url: url))
    }
    
    private func canPlay(type: AnyClass, url: NSURL) -> Bool {
        guard let type = type as? Playback.Type else {
            return false
        }
        
        return type.canPlay(url)
    }
    
    private func addPlugins(container: Container) -> Container {
        for type:UIContainerPlugin.Type in plugins as! [UIContainerPlugin.Type]{
            container.addPlugin(type.init())
        }
        return container
    }
}