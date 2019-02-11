require 'nokogiri'

class LoggerMigration
    def initialize
        puts "Starting logger migration script"
    end

    def migrateFiles(folder, isScriptModule)
        puts "Executing logger migration for: #{folder}"

        Dir.glob(folder).each { | file |  
            if (File.file? file) && !((File.basename file).include? ".element_info.xml")  
                xmlFile = File.new(file)              
                doc = Nokogiri::XML(xmlFile)
                puts "Executing on file: #{File.basename file}"

                doc.remove_namespaces!
                # Contents is stored in different elements for Workflows and Actions 
                # Due to that we have to use different selectors
                xPathSelector = '//workflow-item'
                if (isScriptModule)
                    xPathSelector = '//dunes-script-module'
                end
                
                doc.xpath(xPathSelector).each do | wfItem |
                    xpathElem = wfItem.at_xpath('script')
                    if (xpathElem.to_s.length > 0) 
                        rawStr = xpathElem.text.to_s
                                                                                                
                        containsLog = checkForLogMethods(rawStr)                        
                        if containsLog
                            puts "Found logging usage. Going to migrate..."
                            appendLogger(rawStr)
                            replaceCall(rawStr)

                            valueElement = Nokogiri::XML::Document.new
                            value = valueElement.create_cdata(rawStr)

                            xpathElem.inner_html = value
                            
                            puts "Successfully migrated document. Going to save file..."

                            overWriteFile = (File.dirname file) + "/" + (File.basename file)
                            File.write(overWriteFile, doc.to_xml)
                        end                        
                    end                    
                end                
            end
        }
    end

    # This method is looking for a logger and clazz loader definition and importing it 
    # If definitions have been found it will remove them and put them at the beginning
    # of each workflow/action
    def appendLogger(scriptSection)
        clazzDef = 'var Class = System.getModule("com.vmware.pscoe.library.class").Class();'
        loggerDef = 'var logger = Class.load("com.swisscom.entc.logging", "Logger").fromContext();'

        scriptSection.slice! loggerDef
        scriptSection.prepend(loggerDef + "\n")

        scriptSection.slice! clazzDef
        scriptSection.prepend(clazzDef + "\n")    

    end

    # This method is replacing System.* methods for logging with logger.*
    def replaceCall(scriptSection)
        scriptSection.gsub! 'System.log (', 'logger.info("logMessage",'
        scriptSection.gsub! 'System.trace (', 'logger.trace("logMessage",'
        scriptSection.gsub! 'System.debug (', 'logger.debug("logMessage",'
        scriptSection.gsub! 'System.error (', 'logger.error("logMessage",'
        scriptSection.gsub! 'System.warn (', 'logger.warn("logMessage",'
    end

    def checkForLogMethods(scriptSection)
        containsLog = false
        case 
        when scriptSection.include?('System.log')
            containsLog = true
        when scriptSection.include?('System.trace')
            containsLog = true
        when scriptSection.include?('System.debug')
            containsLog = true
        when scriptSection.include?('System.error')
            containsLog = true
        when scriptSection.include?('System.warn')
            containsLog = true
        end
        containsLog
    end
 end

 loggerMigration = LoggerMigration.new
 
loggerMigration.migrateFiles("/Users/pminkov/Documents/workspace/swisscom/entc-orch/src/main/resources/Workflow/**/*.xml", false)
loggerMigration.migrateFiles("/Users/pminkov/Documents/workspace/swisscom/entc-orch/src/main/resources/ScriptModule/**/*.xml", true)

 # loggerMigration.migrateFiles("/Users/tgdklpa4/IdeaProjects/entc-orch/src/main/resources/Workflow/**/*.xml", false)
 # loggerMigration.migrateFiles("/Users/tgdklpa4/IdeaProjects/entc-orch/src/main/resources/ScriptModule/**/*.xml", true)
 